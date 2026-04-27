#!/bin/bash

TELEGRAM_BOT_TOKEN="<TOKEN>"
TELEGRAM_CHAT_ID="6714653115"

if [ "$CI_JOB_STATUS" == "success" ]; then
    MESSAGE="✅ Pipeline succeeded!

📌 Project: $CI_PROJECT_NAME
📦 Ref: $CI_COMMIT_REF_NAME
🧾 Commit: $CI_COMMIT_MESSAGE
🧑‍💻 Author: $CI_COMMIT_AUTHOR
🔗 Pipeline URL: $CI_PIPELINE_URL
💚 Status: $CI_JOB_STATUS on stage '$CI_JOB_STAGE'

🏁 Finished at: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M') (MSK)"
else
    MESSAGE="❌ Pipeline failed!

📌 Project: $CI_PROJECT_NAME
📦 Ref: $CI_COMMIT_REF_NAME
🧾 Commit: $CI_COMMIT_MESSAGE
🧑‍💻 Author: $CI_COMMIT_AUTHOR
🔗 Pipeline URL: $CI_PIPELINE_URL
💔 Status: $CI_JOB_STATUS on stage '$CI_JOB_STAGE'

🕒 Failed at: $(TZ='Europe/Moscow' date '+%Y-%m-%d %H:%M') (MSK)"
fi

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"  \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$MESSAGE"