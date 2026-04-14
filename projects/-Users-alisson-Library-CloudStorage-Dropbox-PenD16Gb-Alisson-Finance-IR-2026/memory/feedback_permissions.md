---
name: Preferência de permissões — dangerously-skip-permissions
description: Usuário quer rodar Claude sem prompts de aprovação; usa claude --dangerously-skip-permissions
type: feedback
---

Usuário prefere rodar `claude --dangerously-skip-permissions` para evitar confirmações repetidas durante o trabalho.

**Why:** Pediu isso em pelo menos duas sessões distintas (2026-03-27 e 2026-03-30) com as frases "Tem como fazer as coisas sem pedir minha aprovação toda hora?" e "como fazer pra voce fazer tudo sem me perguntar?". Trabalho iterativo de pipeline Python onde parar para confirmar cada bash command é disruptivo.

**How to apply:** Quando em modo bypassado pelo usuário, executar sem pedir confirmação. Quando não estiver nesse modo, concentrar as confirmações apenas em ações verdadeiramente destrutivas ou irreversíveis — não pedir aprovação para leituras, greps ou edições locais rotineiras.
