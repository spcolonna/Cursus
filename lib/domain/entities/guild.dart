import 'domain_strings.dart';
import 'entities.dart';
import 'game_clock.dart';

// ─── El Gremio: contratos del día + paga diaria ──────────────────────────────
// Los contratos son 3 misiones diarias del "tablón del gremio" (reset a
// medianoche local). La paga del gremio es el login diario con racha de 7 días.
// Las recompensas se acreditan al mensajero principal.

// ── Objetivos de contrato ─────────────────────────────────────────────────────
enum ContractGoal {
  deliver,        // entregar paquetes
  resolveEvents,  // resolver eventos (cualquier resultado)
  eventSuccesses, // resolver eventos con éxito
  gradeA,         // entregar con nota A o S
  useSkill,       // usar una opción de cierta habilidad
}

class ContractReward {
  final int denarios;
  final int seals;
  const ContractReward({this.denarios = 0, this.seals = 0});
}

class ContractTemplate {
  final String id;
  final ContractGoal goal;
  final int target;
  final SkillType? skill; // solo para useSkill
  final ContractReward reward;

  const ContractTemplate({
    required this.id,
    required this.goal,
    required this.target,
    this.skill,
    required this.reward,
  });

  /// Texto del tablón (kDomainStrings: ui.contract.<id>).
  String get description => ds('ui.contract.$id');
}

// Pool fácil — recompensa chica en denarios
const _easyPool = <ContractTemplate>[
  ContractTemplate(
    id: 'c_deliver1',
    goal: ContractGoal.deliver, target: 1,
    reward: ContractReward(denarios: 60),
  ),
  ContractTemplate(
    id: 'c_events2',
    goal: ContractGoal.resolveEvents, target: 2,
    reward: ContractReward(denarios: 70),
  ),
  ContractTemplate(
    id: 'c_stealth',
    goal: ContractGoal.useSkill, target: 1, skill: SkillType.stealth,
    reward: ContractReward(denarios: 50),
  ),
  ContractTemplate(
    id: 'c_contacts',
    goal: ContractGoal.useSkill, target: 1, skill: SkillType.contacts,
    reward: ContractReward(denarios: 50),
  ),
  ContractTemplate(
    id: 'c_survival',
    goal: ContractGoal.useSkill, target: 1, skill: SkillType.survival,
    reward: ContractReward(denarios: 50),
  ),
];

// Pool medio — recompensa mayor en denarios
const _mediumPool = <ContractTemplate>[
  ContractTemplate(
    id: 'c_deliver2',
    goal: ContractGoal.deliver, target: 2,
    reward: ContractReward(denarios: 90),
  ),
  ContractTemplate(
    id: 'c_events3',
    goal: ContractGoal.resolveEvents, target: 3,
    reward: ContractReward(denarios: 80),
  ),
  ContractTemplate(
    id: 'c_success2',
    goal: ContractGoal.eventSuccesses, target: 2,
    reward: ContractReward(denarios: 85),
  ),
];

// Pool de Sellos — el tercer contrato del día siempre paga 1 Sello del Gremio
const _sealPool = <ContractTemplate>[
  ContractTemplate(
    id: 'c_seal_gradeA',
    goal: ContractGoal.gradeA, target: 1,
    reward: ContractReward(seals: 1),
  ),
  ContractTemplate(
    id: 'c_seal_success3',
    goal: ContractGoal.eventSuccesses, target: 3,
    reward: ContractReward(seals: 1),
  ),
  ContractTemplate(
    id: 'c_seal_deliver2',
    goal: ContractGoal.deliver, target: 2,
    reward: ContractReward(seals: 1),
  ),
];

const allContractTemplates = [..._easyPool, ..._mediumPool, ..._sealPool];

ContractTemplate contractTemplateById(String id) =>
    allContractTemplates.firstWhere((t) => t.id == id,
        orElse: () => _easyPool.first);

/// Los 3 contratos del día, deterministas por fecha (mismo día = mismo tablón).
List<String> contractIdsForDate(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  return [
    _easyPool[seed % _easyPool.length].id,
    _mediumPool[(seed ~/ 7) % _mediumPool.length].id,
    _sealPool[(seed ~/ 3) % _sealPool.length].id,
  ];
}

/// Reemplazo para el contrato [currentId] (perk del Gremio): el siguiente de
/// su mismo pool que no esté ya en el tablón. Null si no hay otro.
String? rerollContractId(String currentId, Iterable<String> onBoard) {
  for (final pool in [_easyPool, _mediumPool, _sealPool]) {
    final i = pool.indexWhere((t) => t.id == currentId);
    if (i < 0) continue;
    for (var k = 1; k < pool.length; k++) {
      final candidate = pool[(i + k) % pool.length].id;
      if (!onBoard.contains(candidate)) return candidate;
    }
    return null;
  }
  return null;
}

// ── Estado de un contrato del día ─────────────────────────────────────────────
class DailyContract {
  final String templateId;
  final int progress;
  final bool claimed;

  const DailyContract({
    required this.templateId,
    this.progress = 0,
    this.claimed = false,
  });

  ContractTemplate get template => contractTemplateById(templateId);
  bool get completed => progress >= template.target;

  DailyContract copyWith({int? progress, bool? claimed}) => DailyContract(
        templateId: templateId,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
      );
}

// ── Paga del gremio (racha de login) ──────────────────────────────────────────
class DailyPayReward {
  final int denarios;
  final int aureos;
  final int seals;
  const DailyPayReward({this.denarios = 0, this.aureos = 0, this.seals = 0});
}

/// Calendario de 7 días, escalado y cíclico.
const dailyPaySchedule = <DailyPayReward>[
  DailyPayReward(denarios: 30),                 // día 1
  DailyPayReward(denarios: 50),                 // día 2
  DailyPayReward(denarios: 70),                 // día 3
  DailyPayReward(denarios: 100),                // día 4
  DailyPayReward(aureos: 1),                    // día 5
  DailyPayReward(denarios: 150),                // día 6
  DailyPayReward(denarios: 100, aureos: 2, seals: 1), // día 7
];

// ── Estado persistido del gremio ──────────────────────────────────────────────
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// [day] ya pasó respecto de [last] (claves de [dateKey], que ordenan bien
/// como texto). Se compara con orden y no con "distinto": cambiar la zona
/// horaria hacia atrás y adelante no puede volver a abrir un día.
bool isLaterDay(String day, String? last) =>
    last == null || day.compareTo(last) > 0;

class GuildState {
  final String contractsDate;          // yyyy-MM-dd del tablón actual
  final List<DailyContract> contracts;
  final int streakDay;                 // 1-7, último día cobrado
  final String? lastPayDate;           // yyyy-MM-dd del último cobro
  final bool rerollUsed;               // ya cambió un contrato hoy

  const GuildState({
    required this.contractsDate,
    required this.contracts,
    this.streakDay = 0,
    this.lastPayDate,
    this.rerollUsed = false,
  });

  bool get canClaimDailyPay =>
      isLaterDay(dateKey(GameClock.now()), lastPayDate);

  /// Día de racha que corresponde cobrar hoy (1-7, cíclico).
  int get nextPayDay {
    final today = GameClock.now();
    // Por calendario y no restando 24 h: el día del cambio de horario dura 23.
    final yesterday =
        dateKey(DateTime(today.year, today.month, today.day - 1));
    if (lastPayDate == yesterday) return (streakDay % 7) + 1;
    return 1; // se cortó la racha (o primer día)
  }

  DailyPayReward get nextPayReward => dailyPaySchedule[nextPayDay - 1];

  GuildState copyWith({
    String? contractsDate,
    List<DailyContract>? contracts,
    int? streakDay,
    String? lastPayDate,
    bool? rerollUsed,
  }) =>
      GuildState(
        contractsDate: contractsDate ?? this.contractsDate,
        contracts: contracts ?? this.contracts,
        streakDay: streakDay ?? this.streakDay,
        lastPayDate: lastPayDate ?? this.lastPayDate,
        rerollUsed: rerollUsed ?? this.rerollUsed,
      );

  /// Tablón nuevo para hoy.
  factory GuildState.freshFor(DateTime date,
      {int streakDay = 0, String? lastPayDate}) {
    return GuildState(
      contractsDate: dateKey(date),
      contracts: contractIdsForDate(date)
          .map((id) => DailyContract(templateId: id))
          .toList(),
      streakDay: streakDay,
      lastPayDate: lastPayDate,
    );
  }
}
