/* gen_events N [seed] > out.json -- deterministic JSON shaped like a GitHub Archive event dump:
   one array of N event objects (push, create, watch, delete, issues, issue comment, pull request),
   nested actor/repo/payload objects, many URL and hash strings, and long free-text bodies with
   \n, \" and \u escapes and raw UTF-8. Uses the xorshift64 of Goose's bench/cpp/bench.h so a Goose
   or C++ port produces byte-identical text. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint64_t R = 88172645463325252ULL;
static uint64_t nx(void) { R ^= R << 13; R ^= R >> 7; R ^= R << 17; return R; }
static long rnd(long k) { return (long)(nx() % (uint64_t)k); }

static const char *WORDS[] = {
    "the", "a", "fix", "add", "update", "remove", "bug", "test", "build", "release", "merge", "branch",
    "into", "from", "for", "with", "support", "when", "error", "config", "docs", "readme", "version",
    "bump", "dependency", "refactor", "cleanup", "feature", "issue", "pull", "request", "main", "api",
    "client", "server", "handle", "null", "value", "return", "type", "check", "ci", "workflow", "lint",
    "format", "parse", "json", "data", "file", "path", "user", "repo", "commit", "café", "naïve",
    "日本語", "テスト", "ошибка", "größe", "🙂", "v2.1.0", "#123", "(wip)", "x86_64"};
#define NWORDS (sizeof WORDS / sizeof WORDS[0])
static const char *TYPES_W[] = {"login", "dev", "bot", "lab", "hub", "io", "js", "rs", "py", "go"};

static void word(void) { fputs(WORDS[rnd(NWORDS)], stdout); }
static void ident(void) {  /* a login / repo-name-like token */
    int n = 4 + rnd(10);
    for (int i = 0; i < n; i++) putchar('a' + rnd(26));
    if (rnd(3) == 0) printf("-%s", TYPES_W[rnd(10)]);
}
static void hex(int n) { for (int i = 0; i < n; i++) putchar("0123456789abcdef"[rnd(16)]); }
static void text(int nwords) {  /* a JSON string body with escapes */
    putchar('"');
    for (int i = 0; i < nwords; i++) {
        if (i) {
            long r = rnd(24);
            if (r == 0) fputs("\\n", stdout);
            else if (r == 1) fputs("\\n\\n", stdout);
            else if (r == 2) fputs(". ", stdout);
            else if (r == 3) fputs(", ", stdout);
            else putchar(' ');
        }
        long r = rnd(40);
        if (r == 0) fputs("\\\"", stdout), word(), fputs("\\\"", stdout);
        else if (r == 1) fputs("\\u00e9t\\u00e9", stdout);
        else if (r == 2) fputs("`", stdout), word(), fputs("()`", stdout);
        else if (r == 3) fputs("\\t", stdout), word();
        else if (r == 4) fputs("https://github.com/", stdout), ident(), putchar('/'), ident();
        else word();
    }
    putchar('"');
}
static long ID = 34000000000L;
static void date(void) { printf("\"2024-01-%02ldT%02ld:%02ld:%02ldZ\"", 1 + rnd(28), rnd(24), rnd(60), rnd(60)); }
static void user_obj(void) {
    char login[40]; int n = 4 + rnd(10);
    for (int i = 0; i < n; i++) login[i] = 'a' + rnd(26);
    login[n] = 0;
    long id = 1000 + rnd(150000000);
    printf("{\"login\":\"%s\",\"id\":%ld,\"node_id\":\"MDQ6VXNlcj", login, id); hex(8);
    printf("\",\"avatar_url\":\"https://avatars.githubusercontent.com/u/%ld?v=4\",\"gravatar_id\":\"\","
           "\"url\":\"https://api.github.com/users/%s\",\"html_url\":\"https://github.com/%s\","
           "\"followers_url\":\"https://api.github.com/users/%s/followers\","
           "\"following_url\":\"https://api.github.com/users/%s/following{/other_user}\","
           "\"gists_url\":\"https://api.github.com/users/%s/gists{/gist_id}\","
           "\"starred_url\":\"https://api.github.com/users/%s/starred{/owner}{/repo}\","
           "\"repos_url\":\"https://api.github.com/users/%s/repos\","
           "\"events_url\":\"https://api.github.com/users/%s/events{/privacy}\","
           "\"type\":\"User\",\"site_admin\":false}", id, login, login, login, login, login, login, login, login);
}
static void labels(void) {
    int n = rnd(4);
    putchar('[');
    for (int i = 0; i < n; i++) {
        if (i) putchar(',');
        printf("{\"id\":%ld,\"name\":\"", 100000000 + rnd(900000000)); word();
        printf("\",\"color\":\""); hex(6);
        printf("\",\"default\":%s,\"description\":", rnd(5) ? "false" : "true");
        if (rnd(2)) fputs("null", stdout); else text(3 + rnd(8));
        putchar('}');
    }
    putchar(']');
}
static void issue_like(const char *what, long number) {
    printf("{\"url\":\"https://api.github.com/repos/o/r/%s/%ld\",\"id\":%ld,\"number\":%ld,\"title\":",
           what, number, 1000000000 + rnd(1000000000), number);
    text(3 + rnd(10));
    printf(",\"user\":"); user_obj();
    printf(",\"labels\":"); labels();
    printf(",\"state\":\"%s\",\"locked\":false,\"assignee\":null,\"milestone\":null,\"comments\":%ld,"
           "\"created_at\":", rnd(4) ? "open" : "closed", rnd(40));
    date(); printf(",\"updated_at\":"); date();
    printf(",\"closed_at\":null,\"author_association\":\"%s\",\"body\":", rnd(2) ? "NONE" : "CONTRIBUTOR");
    if (rnd(5) == 0) fputs("null", stdout); else text(20 + rnd(rnd(8) ? 250 : 1200));
    printf(",\"reactions\":{\"total_count\":%ld,\"+1\":%ld,\"-1\":0,\"laugh\":0,\"hooray\":0,"
           "\"confused\":0,\"heart\":%ld,\"rocket\":0,\"eyes\":0},\"score\":%.2f}",
           rnd(5), rnd(3), rnd(2), (double)rnd(10000) / 100);
}
static void event(void) {
    long t = rnd(100);
    const char *type = t < 58 ? "PushEvent" : t < 68 ? "CreateEvent" : t < 76 ? "WatchEvent"
                     : t < 80 ? "DeleteEvent" : t < 86 ? "PullRequestEvent" : t < 93 ? "IssueCommentEvent"
                     : "IssuesEvent";
    printf("{\"id\":\"%ld\",\"type\":\"%s\",\"actor\":", ID++, type);
    user_obj();
    char owner[24], name[24]; int a = 3 + rnd(12), b = 3 + rnd(12);
    for (int i = 0; i < a; i++) owner[i] = 'a' + rnd(26);
    owner[a] = 0;
    for (int i = 0; i < b; i++) name[i] = 'a' + rnd(26);
    name[b] = 0;
    long rid = 1000000 + rnd(700000000);
    printf(",\"repo\":{\"id\":%ld,\"name\":\"%s/%s\",\"url\":\"https://api.github.com/repos/%s/%s\"},\"payload\":",
           rid, owner, name, owner, name);
    if (t < 58) {
        int k = 1 + (rnd(4) == 0 ? rnd(6) : 0);
        printf("{\"repository_id\":%ld,\"push_id\":%ld,\"size\":%d,\"distinct_size\":%d,\"ref\":\"refs/heads/",
               rid, 16000000000L + rnd(1000000000), k, k); word();
        printf("\",\"head\":\""); hex(40); printf("\",\"before\":\""); hex(40); printf("\",\"commits\":[");
        for (int i = 0; i < k; i++) {
            if (i) putchar(',');
            printf("{\"sha\":\""); hex(40); printf("\",\"author\":{\"email\":\""); ident();
            printf("@users.noreply.github.com\",\"name\":\""); ident(); printf("\"},\"message\":");
            text(4 + rnd(rnd(6) ? 20 : 160));
            printf(",\"distinct\":true,\"url\":\"https://api.github.com/repos/%s/%s/commits/", owner, name);
            hex(40); printf("\"}");
        }
        printf("]}");
    } else if (t < 68) {
        printf("{\"ref\":"); if (rnd(3)) { putchar('"'); word(); putchar('"'); } else fputs("null", stdout);
        printf(",\"ref_type\":\"%s\",\"master_branch\":\"main\",\"description\":", rnd(2) ? "branch" : "repository");
        if (rnd(2)) fputs("null", stdout); else text(4 + rnd(16));
        printf(",\"pusher_type\":\"user\"}");
    } else if (t < 76) {
        printf("{\"action\":\"started\"}");
    } else if (t < 80) {
        printf("{\"ref\":\""); word(); printf("\",\"ref_type\":\"branch\",\"pusher_type\":\"user\"}");
    } else if (t < 86) {
        long num = 1 + rnd(5000);
        printf("{\"action\":\"%s\",\"number\":%ld,\"pull_request\":", rnd(2) ? "opened" : "closed", num);
        issue_like("pulls", num);
        printf(",\"merged\":%s,\"additions\":%ld,\"deletions\":%ld,\"changed_files\":%ld}",
               rnd(2) ? "true" : "false", rnd(2000), rnd(1000), rnd(50));
    } else {
        long num = 1 + rnd(5000);
        printf("{\"action\":\"%s\",\"issue\":", t < 93 ? "created" : "opened");
        issue_like("issues", num);
        if (t < 93) { printf(",\"comment\":{\"id\":%ld,\"user\":", 1800000000 + rnd(100000000)); user_obj();
            printf(",\"body\":"); text(5 + rnd(rnd(4) ? 60 : 400)); printf("}"); }
        printf("}");
    }
    printf(",\"public\":%s,\"created_at\":", rnd(50) ? "true" : "false");
    date();
    if (rnd(4) == 0) printf(",\"org\":{\"id\":%ld,\"login\":\"%s\",\"url\":\"https://api.github.com/orgs/%s\"}",
                            rnd(100000000), owner, owner);
    putchar('}');
}

int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 1000;
    if (argc > 2) R ^= strtoull(argv[2], 0, 10);
    putchar('[');
    for (long i = 0; i < n; i++) { if (i) fputs(",\n", stdout); event(); }
    fputs("]\n", stdout);
    return 0;
}
