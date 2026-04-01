import 'vaccine_record.dart';

/// 疫苗计划数据模型
///
/// 存储中国国家免疫规划疫苗列表信息，
/// 不存储数据库，仅在内存中使用。
class VaccinePlanItem {
  final String name;              // 疫苗中文名称
  final String? englishName;      // 英文名称
  final String code;              // 疫苗代码（如 "HepB"）
  final List<int> recommendedMonths; // 推荐接种月龄
  final bool isFree;              // 是否免费（免疫规划内）
  final String? notes;            // 备注
  final String disease;           // 预防的疾病

  const VaccinePlanItem({
    required this.name,
    this.englishName,
    required this.code,
    required this.recommendedMonths,
    this.isFree = true,
    this.notes,
    required this.disease,
  });

  /// 计算指定剂次在某个宝宝出生日期下的实际接种日期
  DateTime calculateDate(DateTime birthDate, int doseMonth) {
    final targetMonth = birthDate.month + doseMonth;
    final targetYear = birthDate.year + (targetMonth - 1) ~/ 12;
    final actualMonth = ((targetMonth - 1) % 12) + 1;

    // 处理月底日期边界情况（如2月30日）
    final lastDayOfMonth = DateTime(targetYear, actualMonth + 1, 0).day;
    final targetDay = birthDate.day > lastDayOfMonth ? lastDayOfMonth : birthDate.day;

    return DateTime(targetYear, actualMonth, targetDay);
  }

  /// 获取总剂次数
  int get totalDoses => recommendedMonths.length;
}

/// 疫苗接种计划项
class VaccineScheduleItem {
  final VaccinePlanItem vaccine;   // 疫苗信息
  final DateTime scheduledDate;   // 计划接种日期
  final int doseNumber;            // 剂次（从1开始）
  final int doseMonth;             // 接种月龄

  VaccineScheduleItem({
    required this.vaccine,
    required this.scheduledDate,
    required this.doseNumber,
    required this.doseMonth,
  });

  /// 获取剂次显示文本（第1/1针、第1/3针格式）
  String get doseDisplay {
    return '第$doseNumber/${vaccine.totalDoses}针';
  }

  /// 获取显示名称
  String get displayName => '${vaccine.name} $doseDisplay';
}

/// 自定义疫苗接种计划项
///
/// 用于动态计算用户自定义疫苗的接种计划。
class CustomVaccineScheduleItem {
  final VaccineRecord record;      // 原始记录（第一剂）
  final DateTime scheduledDate;    // 计划接种日期
  final int doseNumber;            // 当前剂次
  final int doseMonth;             // 接种月龄
  final bool isLastDose;           // 是否最后一剂

  const CustomVaccineScheduleItem({
    required this.record,
    required this.scheduledDate,
    required this.doseNumber,
    required this.doseMonth,
    required this.isLastDose,
  });

  /// 获取剂次显示文本
  String get doseDisplay {
    final total = record.totalDoses ?? 1;
    return '第$doseNumber/$total针';
  }

  /// 获取显示名称
  String get displayName => '${record.vaccineName} $doseDisplay';

  /// 获取疫苗名称
  String get vaccineName => record.vaccineName;

  /// 获取预防疾病
  String get disease => record.disease ?? '未知';

  /// 是否免费
  bool get isFree => false; // 自定义疫苗默认自费
}

/// 中国国家免疫规划疫苗列表
///
/// 数据来源：国家免疫规划疫苗儿童免疫程序说明
/// 最新更新时间：2024年
class VaccinePlanData {
  VaccinePlanData._();

  /// 国家免疫规划疫苗（免费）
  static const List<VaccinePlanItem> nationalVaccines = [
    // 乙肝疫苗 - 0、1、6月龄
    VaccinePlanItem(
      name: '乙肝疫苗',
      englishName: 'Hepatitis B',
      code: 'HepB',
      recommendedMonths: [0, 1, 6],
      isFree: true,
      notes: '共3剂',
      disease: '乙型病毒性肝炎',
    ),

    // 卡介苗 - 出生时
    VaccinePlanItem(
      name: '卡介苗',
      englishName: 'BCG',
      code: 'BCG',
      recommendedMonths: [0],
      isFree: true,
      notes: '出生时接种',
      disease: '结核病',
    ),

    // 脊灰疫苗 - 2、3、4月龄，4岁
    VaccinePlanItem(
      name: '脊灰疫苗',
      englishName: 'Polio',
      code: 'IPV/OPV',
      recommendedMonths: [2, 3, 4, 48],
      isFree: true,
      notes: '共4剂',
      disease: '脊髓灰质炎',
    ),

    // 百白破疫苗 - 3、4、5月龄，18月龄
    VaccinePlanItem(
      name: '百白破疫苗',
      englishName: 'DTP',
      code: 'DTP',
      recommendedMonths: [3, 4, 5, 18],
      isFree: true,
      notes: '共4剂',
      disease: '百日咳、白喉、破伤风',
    ),

    // 麻腮风疫苗 - 8、18月龄
    VaccinePlanItem(
      name: '麻腮风疫苗',
      englishName: 'MMR',
      code: 'MMR',
      recommendedMonths: [8, 18],
      isFree: true,
      notes: '共2剂',
      disease: '麻疹、风疹、流行性腮腺炎',
    ),

    // 乙脑疫苗 - 8、24月龄
    VaccinePlanItem(
      name: '乙脑疫苗',
      englishName: 'Japanese Encephalitis',
      code: 'JE',
      recommendedMonths: [8, 24],
      isFree: true,
      notes: '共2剂',
      disease: '流行性乙型脑炎',
    ),

    // A群流脑疫苗 - 6、9月龄
    VaccinePlanItem(
      name: 'A群流脑疫苗',
      englishName: 'Meningococcal A',
      code: 'MenA',
      recommendedMonths: [6, 9],
      isFree: true,
      notes: '共2剂',
      disease: '流行性脑脊髓膜炎（A群）',
    ),

    // A+C群流脑疫苗 - 3、6岁（36、72月龄）
    VaccinePlanItem(
      name: 'A+C群流脑疫苗',
      englishName: 'Meningococcal AC',
      code: 'MenAC',
      recommendedMonths: [36, 72],
      isFree: true,
      notes: '共2剂',
      disease: '流行性脑脊髓膜炎（A群、C群）',
    ),

    // 甲肝疫苗 - 18、24月龄
    VaccinePlanItem(
      name: '甲肝疫苗',
      englishName: 'Hepatitis A',
      code: 'HepA',
      recommendedMonths: [18, 24],
      isFree: true,
      notes: '共2剂',
      disease: '甲型病毒性肝炎',
    ),

    // 白破疫苗 - 6岁（72月龄）
    VaccinePlanItem(
      name: '白破疫苗',
      englishName: 'DT',
      code: 'DT',
      recommendedMonths: [72],
      isFree: true,
      notes: '1剂',
      disease: '白喉、破伤风',
    ),
  ];

  /// 非免疫规划疫苗（自费）
  static const List<VaccinePlanItem> nonNationalVaccines = [
    // 13价肺炎疫苗 - 2、4、6、12月龄
    VaccinePlanItem(
      name: '13价肺炎疫苗',
      englishName: 'PCV13',
      code: 'PCV13',
      recommendedMonths: [2, 4, 6, 12],
      isFree: false,
      notes: '共4剂',
      disease: '肺炎球菌性疾病',
    ),

    // 23价肺炎疫苗 - 24月龄后
    VaccinePlanItem(
      name: '23价肺炎疫苗',
      englishName: 'PPV23',
      code: 'PPV23',
      recommendedMonths: [24],
      isFree: false,
      notes: '1剂',
      disease: '肺炎球菌性疾病',
    ),

    // Hib疫苗 - 2、3、4、18月龄
    VaccinePlanItem(
      name: 'Hib疫苗',
      englishName: 'Hib',
      code: 'Hib',
      recommendedMonths: [2, 3, 4, 18],
      isFree: false,
      notes: '共4剂',
      disease: 'b型流感嗜血杆菌感染',
    ),

    // 轮状病毒疫苗 - 2、4月龄（口服）
    VaccinePlanItem(
      name: '轮状病毒疫苗',
      englishName: 'Rotavirus',
      code: 'RV',
      recommendedMonths: [2, 4],
      isFree: false,
      notes: '共2剂，口服',
      disease: '轮状病毒腹泻',
    ),

    // EV71手足口疫苗 - 6、7月龄
    VaccinePlanItem(
      name: 'EV71手足口疫苗',
      englishName: 'EV71',
      code: 'EV71',
      recommendedMonths: [6, 7],
      isFree: false,
      notes: '共2剂',
      disease: '手足口病',
    ),

    // 水痘疫苗 - 12、48月龄
    VaccinePlanItem(
      name: '水痘疫苗',
      englishName: 'Varicella',
      code: 'Varicella',
      recommendedMonths: [12, 48],
      isFree: false,
      notes: '共2剂',
      disease: '水痘',
    ),

    // 流感疫苗 - 6月龄起每年接种
    VaccinePlanItem(
      name: '流感疫苗',
      englishName: 'Influenza',
      code: 'Influenza',
      recommendedMonths: [6],
      isFree: false,
      notes: '每年接种',
      disease: '流行性感冒',
    ),

    // 脊灰灭活疫苗(IPV) - 2、3、4月龄（替代OPV）
    VaccinePlanItem(
      name: '脊灰灭活疫苗(IPV)',
      englishName: 'IPV',
      code: 'IPV',
      recommendedMonths: [2, 3, 4],
      isFree: false,
      notes: '共3剂，替代脊灰减毒活疫苗',
      disease: '脊髓灰质炎',
    ),
  ];

  /// 获取所有疫苗
  static List<VaccinePlanItem> get allVaccines => [...nationalVaccines, ...nonNationalVaccines];

  /// 获取所有疫苗的总剂次数（仅免疫规划）
  static int get totalDoses {
    return nationalVaccines.fold(0, (sum, vaccine) => sum + vaccine.totalDoses);
  }

  /// 获取所有疫苗的总剂次数（含非免疫规划）
  static int get totalDosesAll {
    return allVaccines.fold(0, (sum, vaccine) => sum + vaccine.totalDoses);
  }

  /// 根据疫苗代码查找疫苗
  static VaccinePlanItem? findByCode(String code) {
    try {
      return allVaccines.firstWhere((v) => v.code == code);
    } catch (_) {
      return null;
    }
  }

  /// 根据疫苗名称查找疫苗
  static VaccinePlanItem? findByName(String name) {
    try {
      return allVaccines.firstWhere((v) => v.name == name);
    } catch (_) {
      return null;
    }
  }
}
