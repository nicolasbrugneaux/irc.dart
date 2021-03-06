part of irc;

/**
 * Base Class for a Client
 */
abstract class ClientBase {

  /**
   * The IRC Parser to use.
   */
  IrcParser get parser;
  
  /**
   * Bot Configuration
   */
  BotConfig get config;
  
  /**
   * The Client's Nickname
   */
  String get nickname;
  
  /**
   * Gets the Channels the Client is in
   */
  Iterable<Channel> get channels;
  
  /**
   * Gets the Server's MOTD
   * Not Ready until the ReadyEvent is posted
   */
  String get motd;
  
  /**
   * Flag for if the Client is connected.
   */
  bool get connected;
  
  /**
   * Sends the [message] to the [target] as a message.
   *
   *      client.message("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void message(String target, String message) {
    var begin = "PRIVMSG ${target} :";

    var all = _handle_message_sending(begin, message);

    for (String msg in all) {
      send(begin + msg);
    }
  }
  
  /**
   * Changes the Client's Nickname
   *
   * [nickname] is the nickname to change to
   */
  void changeNickname(String nickname) {
    send("NICK ${nickname}");
  }

  /**
   * Splits the Messages if required.
   *
   * [begin] is the very beginning of the line (like 'PRIVMSG user :')
   * [input] is the message
   */
  List<String> _handle_message_sending(String begin, String input) {
    var all = [];
    if ((input.length + begin.length) > 454) {
      var max_msg = 454 - (begin.length + 1);
      var sb = new StringBuffer();
      for (int i = 0; i < input.length; i++) {
        sb.write(input[i]);
        if ((i != 0 && (i % max_msg) == 0) || i == input.length - 1) {
          all.add(sb.toString());
          sb.clear();
        }
      }
    } else {
      all = [input];
    }
    return all;
  }

  /**
   * Sends the [input] to the [target] as a notice
   *
   *      client.notice("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void notice(String target, String message) {
    var begin = "NOTICE ${target} :";
    var all = _handle_message_sending(begin, message);
    for (String msg in all) {
      send(begin + msg);
    }
  }
  
  /**
   * Identifies the user with the [nickserv].
   *
   * the default [username] is your configured username.
   * the default [password] is password.
   * the default [nickserv] is NickServ.
   */
  void identify({String username: "PLEASE_INJECT_DEFAULT", String password: "password", String nickserv: "NickServ"}) {
    if (username == "PLEASE_INJECT_DEFAULT") {
      username = config.username;
    }
    message(nickserv, "identify ${username} ${password}");
  }
  
  /**
   * Sends [line] to the server
   *
   *      client.send("WHOIS ExampleUser");
   *
   * Will throw an error if [line] is greater than 510 characters
   */
  void send(String line);
  
  /**
   * Gets a Channel object for the channel's [name].
   * Returns null if no such channel exists.
   */
  Channel channel(String name);
  
  /**
   * Joins the specified [channel].
   */
  void join(String channel) => send("JOIN ${channel}");

  /**
   * Parts the specified [channel].
   */
  void part(String channel) => send("PART ${channel}");
  
  /**
   * Disconnects the Client with the specified [reason].
   * If [force] is true, then the socket is forcibly closed.
   * When it is forcibly closed, a future is returned.
   */
  Future disconnect({String reason: "Client Disconnecting", bool force: false});
  
  /**
   * Connects to the IRC Server
   * Any errors are sent through the [ErrorEvent].
   */
  void connect();
  
  /**
   * Posts a Event to the Event Dispatching System
   * The purpose of this method was to assist in checking for Error Events.
   *
   * [event] is the event to post.
   */
  void post(Event event);
  
  /**
   * Sends [msg] to [target] as a CTCP message
   */
  void ctcp(String target, String msg) => message(target, "\u0001${msg}\u0001");
  
  /**
   * Sends [msg] to [target] as an action.
   */
  void action(String target, String msg) => ctcp(target, "ACTION ${msg}");

  /**
   * Kicks [user] from [channel] with an optional [reason].
   */
  void kick(Channel channel, String user, [String reason]) {
    send("KICK ${channel.name} ${user}${reason != null ? ' :' + reason : ''}");
  }
}
