#!/usr/bin/env python3
"""Synthetic GitHub-event NDJSON for a jq benchmark: gen_events.py <n_events> > out.ndjson

Deterministic (xorshift64, seed 12345), so every run makes the same bytes. The
shape follows a GH Archive hour (2024-01-15-15): the same event-type mix, the same
top-level keys, PushEvents with 1-3 commits, and PullRequestEvents with a large
nested pull_request object, which is where most of the bytes are. Strings carry
the escapes real data has (\\n, \\", \\u00e9 and raw UTF-8). About 3.6 KB per event.
"""
import sys

S = 12345


def nxt():
    global S
    S ^= (S << 13) & 0xFFFFFFFFFFFFFFFF
    S ^= S >> 7
    S ^= (S << 17) & 0xFFFFFFFFFFFFFFFF
    return S


def r(k):
    return nxt() % k


LOW = "abcdefghijklmnopqrstuvwxyz"
ALNUM = LOW + "0123456789-"
WORDS = ["fix", "add", "update", "readme", "test", "build", "the", "for", "and", "docs", "bump",
         "version", "refactor", "api", "config", "support", "remove", "user", "error", "cache"]


def ident(lo, hi):
    return "".join(ALNUM[r(len(ALNUM))] if i else LOW[r(26)] for i in range(lo + r(hi - lo + 1)))


def hexs(n):
    return "".join("0123456789abcdef"[r(16)] for _ in range(n))


def text(nwords):
    out = []
    for i in range(nwords):
        w = WORDS[r(len(WORDS))]
        k = r(40)
        if k == 0:
            w += "\\n"
        elif k == 1:
            w = "\\\"" + w + "\\\""
        elif k == 2:
            w += " café"
        elif k == 3:
            w += " Grüße"
        out.append(w)
    return " ".join(out)


def js(s):
    return '"' + s + '"'


def obj(pairs):
    return "{" + ",".join(js(k) + ":" + v for k, v in pairs) + "}"


USER_URLS = ["followers", "following", "gists", "starred", "subscriptions", "organizations", "repos", "events",
             "received_events"]
REPO_URLS = ["forks", "keys", "collaborators", "teams", "hooks", "issue_events", "events", "assignees", "branches",
             "tags", "blobs", "git_tags", "git_refs", "trees", "statuses", "languages", "stargazers", "contributors",
             "subscribers", "subscription", "commits", "git_commits", "comments", "issue_comment", "contents", "compare",
             "merges", "archive", "downloads", "issues", "pulls", "milestones", "notifications", "labels", "releases",
             "deployments"]
REACTIONS = ["total_count", "+1", "-1", "laugh", "hooray", "confused", "heart", "rocket", "eyes"]


def reactions(url):
    return obj([("url", js(url + "/reactions"))] + [(k, str(r(3) // 2)) for k in REACTIONS])


def user(login, uid):
    return obj([("login", js(login)), ("id", str(uid)), ("node_id", js("U_" + hexs(12))),
                ("avatar_url", js(f"https://avatars.githubusercontent.com/u/{uid}?v=4")),
                ("url", js("https://api.github.com/users/" + login)),
                ("html_url", js("https://github.com/" + login)),
                ] + [(k + "_url", js(f"https://api.github.com/users/{login}/{k}{{/other_user}}" if k == "following" else f"https://api.github.com/users/{login}/{k}"))
                     for k in USER_URLS] + [("type", js("User")), ("site_admin", "false")])


def repo_full(name, rid, owner, oid):
    return obj([("id", str(rid)), ("node_id", js("R_" + hexs(12))), ("name", js(name.split("/")[1])),
                ("full_name", js(name)), ("private", "false"), ("owner", user(owner, oid)),
                ("html_url", js("https://github.com/" + name)),
                ("description", js(text(4 + r(10))) if r(3) else "null"), ("fork", "false"),
                ("url", js("https://api.github.com/repos/" + name)),
                ("created_at", js("2023-%02d-%02dT%02d:%02d:%02dZ" % (1 + r(12), 1 + r(28), r(24), r(60), r(60)))),
                ("size", str(r(100000))), ("stargazers_count", str(r(5000))),
                ("watchers_count", str(r(5000))), ("language", js(["Python", "JavaScript", "Go", "Rust", "C"][r(5)]) if r(4) else "null"),
                ("has_issues", "true"), ("has_wiki", "true" if r(2) else "false"), ("forks_count", str(r(300))),
                ("open_issues_count", str(r(50))), ("topics", "[" + ",".join(js(ident(3, 10)) for _ in range(r(4))) + "]"),
                ("visibility", js("public")), ("default_branch", js("main"))] +
               [(k + "_url", js(f"https://api.github.com/repos/{name}/{k}{{/number}}")) for k in REPO_URLS])


TYPES = ([("PushEvent", 60)] + [("CreateEvent", 14)] + [("PullRequestEvent", 8)] + [("IssueCommentEvent", 4)] +
         [("WatchEvent", 4)] + [("DeleteEvent", 4)] + [("PullRequestReviewEvent", 2)] + [("IssuesEvent", 2)] +
         [("ForkEvent", 1)] + [("ReleaseEvent", 1)])
WHEEL = [t for t, w in TYPES for _ in range(w)]


def event(i):
    t = WHEEL[r(len(WHEEL))]
    login = ident(4, 14)
    uid = 1000 + r(150000000)
    owner = login if r(2) else ident(4, 14)
    oid = uid if owner == login else 1000 + r(150000000)
    name = owner + "/" + ident(3, 20)
    rid = 1000 + r(700000000)
    if t == "PushEvent":
        commits = ",".join(obj([("sha", js(hexs(40))), ("author", obj([("email", js(login + "@users.noreply.github.com")),
                                                                         ("name", js(login))])),
                                 ("message", js(text(3 + r(25)))), ("distinct", "true"),
                                 ("url", js(f"https://api.github.com/repos/{name}/commits/{hexs(40)}"))])
                           for _ in range(1 + r(3)))
        payload = obj([("repository_id", str(rid)), ("push_id", str(16000000000 + r(1000000000))),
                       ("size", "1"), ("distinct_size", "1"), ("ref", js("refs/heads/main")),
                       ("head", js(hexs(40))), ("before", js(hexs(40))), ("commits", "[" + commits + "]")])
    elif t in ("PullRequestEvent", "PullRequestReviewEvent"):
        pr = obj([("url", js(f"https://api.github.com/repos/{name}/pulls/{r(2000)}")), ("id", str(r(2000000000))),
                  ("number", str(r(2000))), ("state", js("open")), ("locked", "false"), ("title", js(text(4 + r(8)))),
                  ("user", user(login, uid)), ("body", js(text(20 + r(400))) if r(3) else "null"),
                  ("created_at", js("2024-01-15T15:%02d:%02dZ" % (r(60), r(60)))), ("merged_at", "null"),
                  ("labels", "[]"), ("draft", "false"), ("head", obj([("label", js(owner + ":" + ident(3, 12))),
                                                                     ("ref", js(ident(3, 12))), ("sha", js(hexs(40))),
                                                                     ("user", user(owner, oid)), ("repo", repo_full(name, rid, owner, oid))])),
                  ("base", obj([("label", js(owner + ":main")), ("ref", js("main")), ("sha", js(hexs(40))),
                                ("user", user(owner, oid)), ("repo", repo_full(name, rid, owner, oid))])),
                  ("author_association", js("OWNER")), ("comments", str(r(10))), ("commits", str(1 + r(20))),
                  ("additions", str(r(5000))), ("deletions", str(r(3000))), ("changed_files", str(1 + r(40)))])
        payload = obj([("action", js("opened")), ("number", str(r(2000))), ("pull_request", pr)])
    elif t in ("IssueCommentEvent", "IssuesEvent"):
        iurl = f"https://api.github.com/repos/{name}/issues/{r(2000)}"
        issue = obj([("url", js(iurl)), ("repository_url", js("https://api.github.com/repos/" + name)),
                     ("id", str(r(2000000000))), ("number", str(r(2000))), ("title", js(text(4 + r(8)))),
                     ("user", user(owner, oid)), ("labels", "[]"), ("state", js("open")), ("assignee", "null"),
                     ("comments", str(r(20))), ("created_at", js("2024-01-1%dT0%d:00:00Z" % (r(5), r(9)))),
                     ("author_association", js("NONE")), ("body", js(text(10 + r(300))) if r(2) else "null"),
                     ("reactions", reactions(iurl)), ("pull_request", obj([("url", js(iurl)), ("html_url", js(iurl))])) if r(2) else ("pull_request", "null")])
        pairs = [("action", js("created")), ("issue", issue)]
        if t == "IssueCommentEvent":
            curl = f"https://api.github.com/repos/{name}/issues/comments/{r(2000000000)}"
            pairs.append(("comment", obj([("url", js(curl)), ("id", str(r(2000000000))), ("user", user(login, uid)),
                                          ("created_at", js("2024-01-15T15:00:00Z")), ("author_association", js("NONE")),
                                          ("body", js(text(5 + r(200)))), ("reactions", reactions(curl))])))
        payload = obj(pairs)
    elif t == "CreateEvent":
        payload = obj([("ref", js(ident(3, 12)) if r(3) else "null"), ("ref_type", js(["branch", "tag", "repository"][r(3)])),
                       ("master_branch", js("main")), ("description", js(text(3 + r(8))) if r(2) else "null"),
                       ("pusher_type", js("user"))])
    elif t == "DeleteEvent":
        payload = obj([("ref", js(ident(3, 12))), ("ref_type", js("branch")), ("pusher_type", js("user"))])
    elif t == "ForkEvent":
        payload = obj([("forkee", repo_full(login + "/" + ident(3, 20), r(700000000), login, uid))])
    elif t == "ReleaseEvent":
        payload = obj([("action", js("published")), ("release", obj([("id", str(r(200000000))), ("tag_name", js("v%d.%d" % (r(5), r(20)))),
                                                                     ("name", js(text(2))), ("body", js(text(30 + r(100)))),
                                                                     ("author", user(login, uid))]))])
    else:
        payload = obj([("action", js("started"))])
    pairs = [("id", js(str(34000000000 + i))), ("type", js(t)),
             ("actor", obj([("id", str(uid)), ("login", js(login)), ("display_login", js(login)),
                            ("gravatar_id", js("")), ("url", js("https://api.github.com/users/" + login)),
                            ("avatar_url", js(f"https://avatars.githubusercontent.com/u/{uid}?"))])),
             ("repo", obj([("id", str(rid)), ("name", js(name)), ("url", js("https://api.github.com/repos/" + name))])),
             ("payload", payload), ("public", "true"),
             ("created_at", js("2024-01-15T15:%02d:%02dZ" % (r(60), r(60))))]
    if r(4) == 0:
        pairs.append(("org", obj([("id", str(r(150000000))), ("login", js(ident(3, 12))), ("gravatar_id", js("")),
                                  ("url", js("https://api.github.com/orgs/x")), ("avatar_url", js("https://avatars.githubusercontent.com/u/1?"))])))
    return obj(pairs)


def main():
    n = int(sys.argv[1])
    w = sys.stdout.write
    for i in range(n):
        w(event(i))
        w("\n")


if __name__ == "__main__":
    main()
