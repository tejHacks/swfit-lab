"""Convert interview.md into assets/interview/questions.json (and validate it)."""
import json, re, sys
src = open(sys.argv[1]).read()
parts = re.split(r"^=== Q: (.+)$", src, flags=re.M)
out, ids = [], set()
for header, body in zip(parts[1::2], parts[2::2]):
    qid, category, level = [x.strip() for x in header.split("|")]
    assert level in {"beginner", "intermediate", "advanced"}, header
    assert qid not in ids, f"duplicate {qid}"
    ids.add(qid)
    question, _, answer = body.strip().partition("\n---\n")
    assert question and answer.strip(), f"{qid}: empty question or answer"
    assert answer.count("```") % 2 == 0, f"{qid}: unbalanced code fence"
    out.append({"id": qid, "category": category, "level": level, "q": question.strip(), "a": answer.strip()})
json.dump(out, open(sys.argv[2], "w"), indent=1, ensure_ascii=False)
from collections import Counter
print(len(out), "questions;", dict(Counter(q["level"] for q in out)), dict(Counter(q["category"] for q in out)))
