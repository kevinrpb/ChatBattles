#!/usr/bin/env python3

import randomname

N = 100
dest = "Sources/ChatBattles/Shared/Names.swift"


def generate(cat: str, n: int) -> list[str]:
    return [randomname.generate(cat) for _ in range(0, n)]


nouns = generate("n/", N)
adjectives = generate("adj/", N)

nouns_list = ''.join(list(map(lambda n: f"\t\t\"{n}\",\n", nouns)))[:-1]
adjectives_list = ''.join(list(map(lambda n: f"\t\t\"{n}\",\n", adjectives)))[:-1]

source = f"""public struct Names {{
	private static let nouns: [String] = [
{nouns_list}
	]

	private static let adjectives: [String] = [
{adjectives_list}
	]

	public static func get() -> String {{
		let noun = nouns.randomElement()!.capitalized
		let adjective = adjectives.randomElement()!.capitalized

		return "\\(adjective)\\(noun)"
	}}
}}
"""

with open(dest, "w") as file:
    file.write(source)
