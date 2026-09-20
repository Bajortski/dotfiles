# greeting.nu — the startup line, drawn from the vault note `Quotes.md`.
# nushell has no greeting hook, so config.nu sources this and calls `greeting`.

const GREETINGS = [
    "“Exercise in futility is better than no exercise at all” - Me"
    "“Sewage, the best word, because it represents the worst stuff” - Me"
    "“Subpar content biweekly, decent content biquarterly” - Me"
    "\"Negligence causes violence, not video games\" - Me"
    "“One for work, one for relaxation” - Mister Sir"
    "\"Given the lack of handrails, I'll crawl up the stairs myself\" - Me"
    "\"I won't let commercialism ruin *my* Christmas!\""
    "\"I'd be a perfectionist if I had the time and money to be one\" - Me"
    "“Believe in yourself, drive directly into that car.” - Me"
    "\"What makes us unique is scar tissue\" - Arin Hanson"
]

def greeting []: nothing -> nothing {
    print ($GREETINGS | shuffle | first)
}
