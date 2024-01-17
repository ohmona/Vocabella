const shortForm = [
  // Deutschland
  ["etw", "etwas"],
  ["etw.", "etwas"],
  ["jdn/etwas", "jemanden etwas"],
  ["jdn./etwas", "jemanden etwas"],
  ["jdn", "jemanden"],
  ["jdn.", "jemanden"],
  ["jdm/etwas", "jemandem etwas"],
  ["jdm./etwas", "jemandem etwas"],
  ["jdm", "jemandem"],
  ["jdm.", "jemandem"],
  ["jmd/etwas", "jemand etwas"],
  ["jmd./etwas", "jemand etwas"],
  ["jmd", "jemand"],
  ["jmd.", "jemand"],
  // La France
  ["qn/qc", "quelqu'un quelque chose"],
  ["qn./qc.", "quelqu'un quelque chose"],
  ["qn", "quelqu'un"],
  ["qn.", "quelqu'un"],
  ["qc", "quelque chose"],
  ["qc.", "quelque chose"],
  // FREEDOM
  ["sb/sth", "somebody something"],
  ["sb./sth.", "somebody something"],
  ["sb", "somebody"],
  ["sb.", "somebody"],
  ["sth", "something"],
  ["sth.", "something"],
];

String formatText(String input) {
  var str = input;

  for (var short in shortForm) {
    final case1 = "${short[0]} ";
    final case2 = " ${short[0]}";

    str = str.replaceAll(case1, "${short[1]} ");
    str = str.replaceAll(case2, " ${short[1]}");
  }

  return str;
}
