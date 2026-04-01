import 'package:flutter/material.dart';
import '../models/vaccine_plan.dart';

/// 疫苗科普页面
///
/// 解释免疫规划和非免疫规划疫苗的区别，
/// 让普通家长能看懂疫苗相关信息。
class VaccineInfoScreen extends StatelessWidget {
  const VaccineInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 什么是免疫规划疫苗
            _buildSection(
              title: '什么是免疫规划疫苗？',
              icon: Icons.shield_outlined,
              iconColor: Colors.green,
              child: _buildNationalVaccineIntro(),
            ),
            const SizedBox(height: 20),

            // 什么是非免疫规划疫苗
            _buildSection(
              title: '什么是非免疫规划疫苗？',
              icon: Icons.paid_outlined,
              iconColor: Colors.blue,
              child: _buildNonNationalVaccineIntro(),
            ),
            const SizedBox(height: 20),

            // 两者的区别
            _buildSection(
              title: '两者有什么区别？',
              icon: Icons.compare_arrows,
              iconColor: Colors.orange,
              child: _buildDifferenceTable(),
            ),
            const SizedBox(height: 20),

            // 免疫规划疫苗列表
            _buildSection(
              title: '免疫规划疫苗有哪些？',
              icon: Icons.checklist,
              iconColor: Colors.green,
              child: _buildNationalVaccineList(),
            ),
            const SizedBox(height: 20),

            // 非免疫规划疫苗列表
            _buildSection(
              title: '非免疫规划疫苗有哪些？',
              icon: Icons.vaccines,
              iconColor: Colors.blue,
              child: _buildNonNationalVaccineList(),
            ),
            const SizedBox(height: 20),

            // 常见疫苗品牌和价格
            _buildSection(
              title: '常见疫苗品牌和价格参考',
              icon: Icons.attach_money,
              iconColor: Colors.purple,
              child: _buildVaccineBrands(),
            ),
            const SizedBox(height: 20),

            // 家长常见问题
            _buildSection(
              title: '家长常见问题',
              icon: Icons.help_outline,
              iconColor: Colors.teal,
              child: _buildFAQ(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF26A69A), size: 24),
          SizedBox(width: 10),
          Text(
            '疫苗知识科普',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// 免疫规划疫苗介绍
  Widget _buildNationalVaccineIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '免疫规划疫苗是指由政府免费向公民提供的疫苗，公民应当依照政府的规定接种的疫苗。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D2D2D),
            height: 1.6,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '简单理解：国家买单，宝宝免费打。',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '这些疫苗经过大量人群接种验证，安全性高，是每个宝宝都应该接种的基础疫苗。主要预防乙肝、结核病、脊髓灰质炎、百日咳、白喉、破伤风、麻疹、风疹、流行性腮腺炎、乙型脑炎、流行性脑脊髓膜炎、甲型病毒性肝炎等传染病。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D2D2D),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  /// 非免疫规划疫苗介绍
  Widget _buildNonNationalVaccineIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '非免疫规划疫苗是指由公民自费并且自愿接种的疫苗。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D2D2D),
            height: 1.6,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '简单理解：自己买单，给宝宝额外保护。',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '虽然不是国家强制接种，但这类疫苗同样重要，可以预防更多疾病或提供更全面的保护。比如肺炎球菌引起的肺炎、脑膜炎，轮状病毒引起的腹泻，EV71引起的手足口病等。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D2D2D),
            height: 1.6,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '经济条件允许的情况下，建议尽量接种，为宝宝提供更全面的保护。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 两者区别对比表
  Widget _buildDifferenceTable() {
    return Column(
      children: [
        // 表头
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '对比项',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '免疫规划疫苗',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '非免疫规划疫苗',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 数据行
        _buildDiffRow('费用', '免费', '自费'),
        _buildDiffRow('是否强制', '必须接种', '自愿接种'),
        _buildDiffRow('疫苗数量', '约10种（22剂次）', '约8种以上'),
        _buildDiffRow('预防疾病', '基础传染病', '更多疾病'),
        _buildDiffRow('接种地点', '社区卫生院', '社区卫生院/医院'),
        _buildDiffRow('重要性', '同等重要', '同等重要'),
      ],
    );
  }

  Widget _buildDiffRow(String item, String national, String nonNational) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              national,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              nonNational,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 免疫规划疫苗列表
  Widget _buildNationalVaccineList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '共10种疫苗，约22剂次（从出生到6岁）',
          style: TextStyle(
            fontSize: 13,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...VaccinePlanData.nationalVaccines.map((vaccine) => _buildVaccineCard(
              vaccine.name,
              vaccine.disease,
              _formatMonths(vaccine.recommendedMonths),
              vaccine.totalDoses,
              true,
            )),
      ],
    );
  }

  /// 非免疫规划疫苗列表
  Widget _buildNonNationalVaccineList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '常见8种疫苗（需自费）',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...VaccinePlanData.nonNationalVaccines.map((vaccine) => _buildVaccineCard(
              vaccine.name,
              vaccine.disease,
              _formatMonths(vaccine.recommendedMonths),
              vaccine.totalDoses,
              false,
            )),
      ],
    );
  }

  Widget _buildVaccineCard(String name, String disease, String months, int doses, bool isFree) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isFree ? Colors.green : Colors.blue).withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isFree ? Colors.green : Colors.blue).withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFree ? Colors.green.withAlpha(25) : Colors.blue.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isFree ? Icons.shield_outlined : Icons.vaccines_outlined,
              size: 18,
              color: isFree ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '预防：$disease',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isFree ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isFree ? '免费' : '自费',
                  style: TextStyle(
                    fontSize: 10,
                    color: isFree ? Colors.green[600] : Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$doses剂次',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                months,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonths(List<int> months) {
    if (months.isEmpty) return '';
    final formatted = months.map((m) {
      if (m == 0) return '出生';
      if (m < 12) return '${m}月龄';
      final y = m ~/ 12;
      final rm = m % 12;
      if (rm == 0) return '${y}岁';
      return '${y}岁${rm}月';
    }).join('、');
    return formatted;
  }

  /// 常见疫苗品牌和价格
  Widget _buildVaccineBrands() {
    final vaccines = [
      _VaccineBrandItem(
        name: '13价肺炎疫苗',
        brands: ['辉瑞（沛儿13）', '沃森（维民菲乐）', '民海（维菠萝）'],
        priceRange: '约600-800元/剂',
        totalDoses: '4剂',
        totalPrice: '约2400-3200元',
        disease: '肺炎球菌引起的肺炎、脑膜炎等',
      ),
      _VaccineBrandItem(
        name: '23价肺炎疫苗',
        brands: ['默沙东（纽莫法）', '成都生物', '沃森'],
        priceRange: '约200-300元/剂',
        totalDoses: '1-2剂',
        totalPrice: '约200-600元',
        disease: '肺炎球菌引起的肺炎等',
      ),
      _VaccineBrandItem(
        name: 'Hib疫苗',
        brands: ['巴斯德（安尔宝）', '沃森', '民海', '兰州生物'],
        priceRange: '约100-150元/剂',
        totalDoses: '4剂',
        totalPrice: '约400-600元',
        disease: 'b型流感嗜血杆菌感染（脑膜炎、肺炎等）',
      ),
      _VaccineBrandItem(
        name: '轮状病毒疫苗',
        brands: ['默沙东（ RotaTeq 五价）', '兰州生物（罗特威 单价）'],
        priceRange: '约150-300元/剂',
        totalDoses: '2-3剂',
        totalPrice: '约300-900元',
        disease: '轮状病毒引起的腹泻',
      ),
      _VaccineBrandItem(
        name: 'EV71手足口疫苗',
        brands: ['北京科兴（益尔来福）', '武汉生物', '医科院生物所'],
        priceRange: '约150-200元/剂',
        totalDoses: '2剂',
        totalPrice: '约300-400元',
        disease: 'EV71型手足口病',
      ),
      _VaccineBrandItem(
        name: '水痘疫苗',
        brands: ['长春百克', '上海生物', '科兴', '巴斯德'],
        priceRange: '约100-150元/剂',
        totalDoses: '2剂',
        totalPrice: '约200-300元',
        disease: '水痘',
      ),
      _VaccineBrandItem(
        name: '流感疫苗',
        brands: ['巴斯德（凡尔灵）', '科兴（安尔来福）', '长春生物', '华兰生物'],
        priceRange: '约50-150元/剂',
        totalDoses: '每年1-2剂',
        totalPrice: '约50-300元/年',
        disease: '流行性感冒',
      ),
      _VaccineBrandItem(
        name: '脊灰灭活疫苗(IPV)',
        brands: ['巴斯德（爱宝维）', '北京生物', '科兴'],
        priceRange: '约150-200元/剂',
        totalDoses: '4剂（含免费）',
        totalPrice: '约300-600元（替代部分免费）',
        disease: '脊髓灰质炎',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '价格仅供参考，实际价格因地区、接种点而异。具体以当地接种单位报价为准。',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...vaccines.map((item) => _buildBrandCard(item)),
      ],
    );
  }

  Widget _buildBrandCard(_VaccineBrandItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 疫苗名称
          Row(
            children: [
              const Icon(Icons.vaccines_outlined, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 预防疾病
          Text(
            '预防：${item.disease}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          // 品牌
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  '品牌：',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
              Expanded(
                child: Text(
                  item.brands.join('、'),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 价格信息
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  '价格：',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
              Expanded(
                child: Text(
                  '${item.priceRange}（共${item.totalDoses}，合计约${item.totalPrice}）',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 常见问题
  Widget _buildFAQ() {
    final faqs = [
      _FAQItem(
        q: '非免疫规划疫苗是不是不重要？',
        a: '不是！免疫规划和非免疫规划疫苗同样重要。免疫规划疫苗预防的是最基础、最常见的传染病；非免疫规划疫苗可以预防更多疾病，给宝宝更全面的保护。经济条件允许时，建议尽量接种。',
      ),
      _FAQItem(
        q: '免疫规划疫苗可以推迟接种吗？',
        a: '建议按程序及时接种。但如果宝宝身体不适，可以推迟接种，待恢复后尽快补种。推迟接种不会影响疫苗效果，但会增加感染风险。',
      ),
      _FAQItem(
        q: '同一种疫苗有免费和自费两种，怎么选？',
        a: '如果免疫规划中有该疫苗（如脊灰疫苗），建议先完成免疫规划疫苗接种。如需选择自费产品替代（如用IPV替代OPV），可根据自身情况选择。',
      ),
      _FAQItem(
        q: '接种疫苗后会有不良反应吗？',
        a: '部分宝宝接种后可能出现轻微发热、接种部位红肿、食欲不振等反应，通常1-2天自行消退。若出现高热、持续哭闹或皮疹等严重反应，应及时就医。',
      ),
      _FAQItem(
        q: '宝宝身体不适时可以接种疫苗吗？',
        a: '轻微感冒、体温正常的情况下可以接种。但如果发热、腹泻、急性疾病发作期或有严重慢性疾病，建议暂缓接种，待恢复后再接种。',
      ),
      _FAQItem(
        q: '到哪里接种疫苗？',
        a: '免疫规划疫苗通常在社区卫生院接种。非免疫规划疫苗也可以在社区卫生院、部分医院或私立接种门诊接种。建议到正规接种单位接种。',
      ),
    ];

    return Column(
      children: faqs.map((faq) => _buildFAQItem(faq)).toList(),
    );
  }

  Widget _buildFAQItem(_FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.help_outline, size: 14, color: Colors.teal),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.q,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
        children: [
          Text(
            item.a,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 疫苗品牌数据
class _VaccineBrandItem {
  final String name;
  final List<String> brands;
  final String priceRange;
  final String totalDoses;
  final String totalPrice;
  final String disease;

  const _VaccineBrandItem({
    required this.name,
    required this.brands,
    required this.priceRange,
    required this.totalDoses,
    required this.totalPrice,
    required this.disease,
  });
}

/// 常见问题数据
class _FAQItem {
  final String q;
  final String a;

  const _FAQItem({required this.q, required this.a});
}
