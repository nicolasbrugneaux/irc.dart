part of irc.parser;

/**
 * Regular Expression based IRC Parser
 */
class RegexIrcParser extends IrcParser {
  /**
   * Basic Regular Expression for IRC Parsing.
   *
   * Expression: ^([\@A-Za-z\;\=\/\\]*)?(?:\ )? ?(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$
   */
  static final REGEX = new RegExp(r"^([\@A-Za-z\;\=\/\\]*)?(?:\ )? ?(?:[:](\S+) )?(\S+)(?: (?!:)(.+?))?(?: [:](.+))?$");

  @override
  Message convert(String line) {
    List<String> match;
    {
      var parsed = REGEX.firstMatch(line);
      match = new List.generate(parsed.groupCount + 1, parsed.group);
      if (match[1] == "PING") {
        match = [match[0], null, null, match[1], null, match[3].substring(1)];
      }
    }
    var tagStuff = match[1];
    var hostmask = match[2];
    var command = match[3];
    var param_string = match[4];
    var msg = match[5];
    var parameters = param_string != null ? param_string.split(" ") : [];
    var tags = <String, dynamic>{};
    
    if (tagStuff != null && tagStuff.trim().isNotEmpty) {
      tags = IrcParserSupport.parseTags(tagStuff);
    }

    return new Message(line: line, hostmask: hostmask, command: command, message: msg, parameters: parameters, tags: tags);
  }
}
