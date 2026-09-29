extends RefCounted
class_name NPCRoster


static func build(seed: int) -> Array[NPCProfile]:
	var pool: Array[NPCProfile] = [
		NPCProfile.new({
			"id": "calm_regular",
			"display_name": "지민",
			"trait_label": "차분한 단골",
			"action_speed": 1.00,
			"patience": 1.25,
			"request_bias": 0.65,
			"tip_multiplier": 1.00,
			"warning_line": "천천히 하셔도 돼요.",
			"miss_line": "아, 요청은 다음에 해도 돼요.",
		}),
		NPCProfile.new({
			"id": "impatient_reg",
			"display_name": "맥스",
			"trait_label": "성급한 레귤러",
			"action_speed": 0.72,
			"patience": 0.62,
			"request_bias": 0.85,
			"tip_multiplier": 1.10,
			"warning_line": "딜러, 진행 좀요.",
			"miss_line": "이 테이블 왜 이렇게 느려요?",
		}),
		NPCProfile.new({
			"id": "new_player",
			"display_name": "소연",
			"trait_label": "초보 플레이어",
			"action_speed": 1.28,
			"patience": 1.05,
			"request_bias": 1.35,
			"tip_multiplier": 0.95,
			"warning_line": "저... 이거 맞게 된 거죠?",
			"miss_line": "저 아직 잘 모르겠어요.",
		}),
		NPCProfile.new({
			"id": "chatty_regular",
			"display_name": "토니",
			"trait_label": "말 많은 단골",
			"action_speed": 0.92,
			"patience": 0.82,
			"request_bias": 1.55,
			"tip_multiplier": 1.08,
			"warning_line": "딜러~ 내 거 잊은 거 아니죠?",
			"miss_line": "아까부터 말했는데~",
		}),
		NPCProfile.new({
			"id": "demanding_vip",
			"display_name": "김사장",
			"trait_label": "까다로운 VIP",
			"action_speed": 0.78,
			"patience": 0.55,
			"request_bias": 1.30,
			"tip_multiplier": 1.45,
			"warning_line": "딜러, 바로 처리해 주세요.",
			"miss_line": "서비스가 이래서야 되겠어요?",
		}),
		NPCProfile.new({
			"id": "relaxed_tourist",
			"display_name": "찰리",
			"trait_label": "느긋한 관광객",
			"action_speed": 1.38,
			"patience": 1.48,
			"request_bias": 0.50,
			"tip_multiplier": 1.00,
			"warning_line": "No rush, dealer.",
			"miss_line": "It's okay. Next time.",
		}),
	]

	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: NPCProfile = pool[i]
		pool[i] = pool[j]
		pool[j] = temp

	return pool
