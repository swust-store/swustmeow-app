import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:miaomiaoswust/core/activity/activity.dart';
import 'package:miaomiaoswust/utils/time.dart';

Solar lunarToSolar(int year, int month, int day) =>
    Lunar.fromYmd(year, month, day).getSolar();

String lunarToDateString(int year, int month, int day) =>
    lunarToSolar(year, month, day).dateString;

Solar? getJieQi(DateTime date, String name) =>
    Lunar.fromDate(date).getJieQiTable()[name];

String? getSolarDurationDateString(Solar? start, int days) {
  if (start == null) return null;
  final end = start.nextDay(days - 1);
  return '${start.dateString}-${end.dateString}';
}

String getLunarDurationDateString(
    int year, int startMonth, int startDay, int days) {
  final start = Lunar.fromYmd(year, startMonth, startDay).getSolar();
  return getSolarDurationDateString(start, days - 1)!;
}

final commonActivities = [
  Activity.common(name: '正式上课', dateString: '2025.02.24'),
  Activity.common(name: '毕业典礼', dateString: '2025.06.20'),
];

final shifts = ['2025.04.27']
    .map((dateString) => Activity.shift(dateString: dateString))
    .toList();

// TODO 添加用户生日检测
// TODO 为之后的节日特效等功能做铺垫
final festivals = [
  // 跨年前夕：12.31
  Activity.hidden(dateString: '12.31', greetings: ['一起迎接新年吧🌟', '跨年倒计时🥳']),

  // 元旦：01.01
  Activity.festival(
      name: '元旦',
      dateString: '01.01',
      greetingsGetter: (DateTime date) => [
            '${date.year + 1}，你好🥳',
            '新的一年🎉',
            'Happy New Year🎉',
            '元旦快乐🥳',
            '庆祝地球公转一周🎉',
            '愿新年带来新希望✨',
            '新的起点 新的梦想🌟'
          ]),

  // 除夕：正月初一前一天
  Activity.festival(
      name: '除夕',
      dateStringGetter: (DateTime date) =>
          lunarToSolar(date.year, 1, 1).nextDay(-1).dateString,
      greetings: ['新年的钟声即将敲响🎉', '新年倒计时🥳']),

  // 春节：正月初一到正月初七
  Activity.festival(
    name: '春节',
    dateStringGetter: (DateTime date) =>
        getLunarDurationDateString(date.year, 1, 1, 7),
    greetings: [
      'Happy New Year🎉',
      '新年快乐🎉',
      '一起看烟花吧🎆',
      '新年快乐 红包拿来🧧',
      '炮竹声中一岁除🧨',
      '新春大吉 幸福安康🎉',
      '阖家欢乐 平安喜乐🏠',
      '红红火火过大年🔥'
    ],
  ),

  // 元宵节：正月十五
  Activity.festival(
      name: '元宵节',
      dateStringGetter: (DateTime date) => lunarToDateString(date.year, 1, 15),
      greetings: ['元宵节快乐🥳', '猜灯谜 吃汤圆🤪', '灯笼照亮夜空🏮', '汤圆甜在心里🥰']),

  // 妇女节：03.08
  Activity.festival(
      name: '妇女节',
      holiday: false,
      dateString: '03.08',
      greetings: ['女神们节日快乐👑']),

  // 愚人节：04.01
  Activity.festival(
      name: '愚人节',
      holiday: false,
      dateString: '04.01',
      greetings: ['今天你被骗了吗😆', '笑一笑十年少😊']),

  // 清明节：清明节气当天，持续3天
  Activity.festival(
      name: '清明节',
      dateStringGetter: (DateTime date) =>
          getSolarDurationDateString(getJieQi(date, '清明'), 3) ?? '04.04-04.06',
      greetings: ['缅怀先人🕯️', '思念故人 心中缅怀🕯️', '清明时节雨纷纷🌧️']),

  // 劳动节：05.01-05.05
  Activity.festival(
      name: '劳动节',
      dateString: '05.01-05.05',
      greetings: ['劳动节快乐🥳', '劳动最光荣💪']),

  // 青年节：05.04
  Activity.festival(name: '青年节', dateString: '05.04'),

  // 端午节：五月初五，持续三天
  Activity.festival(
      name: '端午节',
      dateStringGetter: (DateTime date) =>
          getLunarDurationDateString(date.year, 5, 5, 3),
      greetings: ['端午节安康🐲', '吃粽子 赛龙舟🐲']),

  // 国庆前夕：10.01前一天
  Activity.hidden(
      dateStringGetter: (DateTime date) =>
          DateTime(date.year, 10, 1).yesterday.dateString,
      greetings: ['国庆倒计时🥳', '国庆狂欢倒计时🎉', '准备好迎接国庆了吗🥳']),

  // 国庆节：10.01，根据官方文件得知放8天
  // TODO 优化此类问题的解决方式
  Activity.festival(
      name: '国庆节',
      dateString: '10.01-10.08',
      greetings: ['举国同庆🎉', '祖国母亲生日快乐🥳', '国旗飘扬心中🇨🇳', '愿祖国繁荣昌盛🌟']),

  // 中秋节：八月十五，但不放假
  Activity.festival(
      name: '中秋节',
      holiday: false,
      dateStringGetter: (DateTime date) => lunarToDateString(date.year, 8, 15),
      greetings: ['中秋节快乐🥳', '月圆人团圆✨', '赏月吃月饼🥮']),

  // 万圣夜和万圣节：10.31-11.1
  Activity.festival(
      name: '万圣节',
      holiday: false,
      dateString: '10.31-11.1',
      greetings: ['Happy Halloween🎃', '不给糖就捣蛋👻🍬', '万圣节快乐👻😈']),

  // 圣诞节：12.25
  Activity.festival(
      name: '圣诞节',
      holiday: false,
      dateString: '12.25',
      greetings: ['Merry Christmas🎄', '圣诞节快乐🎄', '圣诞老人带着礼物来啦🎁']),

  // 寒假
  Activity.festival(
      name: '寒假', dateString: '2025.01.13-2025.02.23', greetings: ['寒假快乐！']),

  // 暑假
  Activity.festival(
      name: '暑假', dateString: '2025.07.14-2025.08.21', greetings: ['暑假快乐！'])
];

// TODO 使用获取服务器 JSON 数据并解析的方式
final activities = commonActivities + shifts + festivals;
