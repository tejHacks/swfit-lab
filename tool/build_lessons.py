"""Split lesson bundles into individual Markdown files + curriculum.json, and validate them.

Usage: python3 build_lessons.py <content_dir> <output_dir>
Output: <output_dir>/<course>/<slug>.md and <output_dir>/<course>/curriculum.json
"""
import json
import re
import sys
from pathlib import Path

CURRICULUM = {
    "swift": {
        "title": "Swift: Zero to Advanced",
        "tagline": "Learn Swift 6 the right way: fundamentals, types, memory, concurrency, SwiftUI and advanced topics.",
        "modules": [
            ("start", "Getting Started", "beginner", "rocket_launch", "#F05138",
             "What Swift is, setting up Xcode, and your first program.",
             ["what-is-swift", "setup-xcode", "first-program"]),
            ("fundamentals", "Swift Fundamentals", "beginner", "code", "#E8590C",
             "Variables, types, operators, strings, optionals and control flow.",
             ["variables-constants", "types-and-inference", "operators", "strings", "optionals", "control-flow"]),
            ("collections", "Collections & Functions", "beginner", "data_object", "#D97706",
             "Arrays, dictionaries, sets, functions and closures.",
             ["arrays", "dictionaries-sets", "functions", "closures", "higher-order-functions"]),
            ("types", "Building Types", "intermediate", "category", "#2563EB",
             "Structs, classes, enums, properties, initializers, protocols, extensions and generics.",
             ["structs", "classes", "enums", "properties", "initializers", "protocols", "extensions", "generics"]),
            ("safety", "Errors, Memory & Access", "intermediate", "memory", "#7C3AED",
             "Error handling, ARC and retain cycles, and access control.",
             ["error-handling", "memory-arc", "access-control"]),
            ("concurrency", "Concurrency", "advanced", "sync", "#0E7490",
             "async/await, tasks, actors, Sendable and Swift 6 data-race safety.",
             ["async-await", "tasks-and-groups", "actors-sendable", "main-actor"]),
            ("swiftui", "SwiftUI & iOS", "intermediate", "phone_iphone", "#16A34A",
             "Build real iOS apps: views, state, Observation, navigation, networking and SwiftData.",
             ["swiftui-basics", "state-and-binding", "observable", "lists-navigation", "networking-codable", "swiftdata"]),
            ("advanced", "Advanced Swift", "advanced", "workspace_premium", "#DC2626",
             "Associated types, property wrappers, macros, ownership, testing and architecture.",
             ["protocols-advanced", "property-wrappers", "macros", "noncopyable-ownership", "swift-testing", "app-architecture"]),
        ],
    },
}

FRONT = re.compile(r"^---\n(.*?)\n---\n", re.S)
QUIZ = re.compile(r"```quiz\n(.*?)\n```", re.S)


def parse(path_name, text):
    m = FRONT.match(text)
    assert m, f"{path_name}: missing front matter"
    meta = {}
    for line in m.group(1).splitlines():
        k, _, v = line.partition(":")
        meta[k.strip()] = v.strip()
    for key in ("title", "summary", "minutes"):
        assert meta.get(key), f"{path_name}: front matter needs {key}"
    int(meta["minutes"])
    quizzes = QUIZ.findall(text)
    assert len(quizzes) <= 1, f"{path_name}: more than one quiz block"
    if quizzes:
        qs = json.loads(quizzes[0])
        for q in qs:
            assert set(q) == {"q", "options", "answer", "why"}, f"{path_name}: bad quiz keys {q.keys()}"
            assert 0 <= q["answer"] < len(q["options"]), f"{path_name}: answer index out of range: {q['q']}"
    callouts_open = len(re.findall(r"^:::(tip|note|warning|analogy)\s*$", text, re.M))
    callouts_close = len(re.findall(r"^:::\s*$", text, re.M))
    assert callouts_open == callouts_close, f"{path_name}: unbalanced ::: callouts"
    assert text.count("```") % 2 == 0, f"{path_name}: unbalanced code fences"
    return meta, (len(qs) if quizzes else 0)


def main(content_dir, out_dir):
    content_dir, out_dir = Path(content_dir), Path(out_dir)
    lessons = {}
    for bundle in sorted(content_dir.glob("*.md")):
        parts = re.split(r"^=== FILE: (.+?) ===\n", bundle.read_text(), flags=re.M)
        for name, body in zip(parts[1::2], parts[2::2]):
            slug = name.removesuffix(".md")
            assert slug not in lessons, f"duplicate lesson {slug}"
            lessons[slug] = body.strip() + "\n"

    used = set()
    total_q = 0
    for course, cfg in CURRICULUM.items():
        cdir = out_dir / course
        cdir.mkdir(parents=True, exist_ok=True)
        modules = []
        for mid, title, level, icon, color, desc, slugs in cfg["modules"]:
            entries = []
            for slug in slugs:
                assert slug in lessons, f"{course}/{mid}: lesson file missing: {slug}"
                assert slug not in used, f"lesson used twice: {slug}"
                used.add(slug)
                meta, nq = parse(slug, lessons[slug])
                total_q += nq
                (cdir / f"{slug}.md").write_text(lessons[slug])
                entries.append({"slug": slug, "title": meta["title"], "summary": meta["summary"],
                                "minutes": int(meta["minutes"]), "questions": nq})
            modules.append({"id": mid, "title": title, "level": level, "icon": icon, "color": color,
                            "description": desc, "lessons": entries})
        (cdir / "curriculum.json").write_text(json.dumps(
            {"course": course, "title": cfg["title"], "tagline": cfg["tagline"], "modules": modules}, indent=2) + "\n")
        n = sum(len(m["lessons"]) for m in modules)
        print(f"{course}: {len(modules)} modules, {n} lessons")

    unused = set(lessons) - used
    assert not unused, f"lessons not in any module: {unused}"
    print(f"OK: {len(used)} lessons, {total_q} quiz questions")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
