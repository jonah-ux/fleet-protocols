# OUTREACH-GATE Protocol

> **TRIGGER:** You are about to send a message to someone outside the fleet: a shop owner, lead, vendor, Telegram to Jonah, email, SMS.

## CHECKLIST

- [ ] Is it within send hours? (7 AM - 8 PM CT for SMS -- TCPA violation risk)
- [ ] Is the recipient correct? (not a test number, not Jonah personal number)
- [ ] Is the content accurate? (shop name, offer, facts all correct)
- [ ] Is the tone appropriate? (professional, not robotic)
- [ ] Has it been SAM-approved? (if outreach)
- [ ] Does it contain the right phone number? ((760) 493-6821, NOT Jonah personal)
- [ ] Are there em-dashes or special characters that break SMS encoding?
- [ ] Has this person already been contacted today? (do not double-message)
- [ ] If Telegram to Jonah: is this worth interrupting him? (run WORTH-IT first)

## HARD STOPS

- NEVER send before 7 AM or after 8 PM recipient local time
- NEVER include Jonah personal phone number
- NEVER send to a DND-flagged contact
- NEVER send template-only outreach (must be LLM-composed)
- NEVER send without SAM approval for first-touch outreach

## VERIFY AFTER SEND

- Check the delivery status (Salesmsg API, Telegram response code)
- Log to `agent_ops_logs` with action_type `outreach`
- If delivery failed, do NOT retry blindly -- check why first
