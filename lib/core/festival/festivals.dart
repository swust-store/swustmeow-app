import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:miaomiaoswust/utils/time.dart';

import '../values.dart';
import 'festival.dart';

DateTime get now => Values.now;

Solar lunarToSolar(int month, int day) =>
    Lunar.fromYmd(now.year, month, day).getSolar();

String lunarToDateString(int month, int day) =>
    lunarToSolar(month, day).dateString;

Solar? getJieQi(String name) => Lunar.fromDate(now).getJieQiTable()[name];

String? getSolarDurationDateString(Solar? start, int days) {
  if (start == null) return null;
  final end = start.nextDay(days - 1);
  return '${start.dateString}-${end.dateString}';
}

String getLunarDurationDateString(int startMonth, int startDay, int days) {
  final start = Lunar.fromYmd(now.year, startMonth, startDay).getSolar();
  return getSolarDurationDateString(start, days - 1)!;
}

// TODO 添加用户生日检测
// TODO 为之后的节日特效等功能做铺垫
List<Festival> festivals = [
  // 跨年前夕：12.31
  const Festival(dateString: '12.31', greetings: ['一起迎接新年吧🌟', '跨年倒计时🥳']),

  // 元旦：01.01，持续7天
  Festival(dateString: '01.01-01.07', greetings: [
    '${now.year + 1}，你好🥳',
    '新的一年🎉',
    'Happy New Year🎉',
    '元旦快乐🥳',
    '庆祝地球公转一周🎉',
    '愿新年带来新希望✨',
    '新的起点 新的梦想🌟'
  ]),

  // 除夕：正月初一前一天
  Festival(
      dateString: lunarToSolar(1, 1).nextDay(-1).dateString,
      greetings: ['新年的钟声即将敲响🎉', '新年倒计时🥳']),

  // 春节：正月初一到正月初七
  Festival(
    dateString: getLunarDurationDateString(1, 1, 7),
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
  Festival(
      dateString: lunarToDateString(1, 15),
      greetings: ['元宵节快乐🥳', '猜灯谜 吃汤圆🤪', '灯笼照亮夜空🏮', '汤圆甜在心里🥰']),

  // 妇女节：03.08
  const Festival(dateString: '03.08', greetings: ['女神们节日快乐👑']),

  // 愚人节：04.01
  const Festival(dateString: '04.01', greetings: ['今天你被骗了吗😆', '笑一笑十年少😊']),

  // 清明节：清明节气当天，持续3天
  Festival(
      dateString:
          getSolarDurationDateString(getJieQi('清明'), 3) ?? '04.04-04.06',
      greetings: ['缅怀先人🕯️', '思念故人 心中缅怀🕯️', '清明时节雨纷纷🌧️']),

  // 劳动节：05.01
  const Festival(dateString: '05.01-05.05', greetings: ['劳动节快乐🥳', '劳动最光荣💪']),

  // 端午节：五月初五
  Festival(
      dateString: lunarToDateString(5, 5), greetings: ['端午节安康🐲', '吃粽子 赛龙舟🐲']),

  // 国庆前夕：10.01前一天
  Festival(
      dateString: DateTime(now.year, 10, 1).yesterday.dateString,
      greetings: ['国庆倒计时🥳', '国庆狂欢倒计时🎉', '准备好迎接国庆了吗🥳']),

  // 国庆节：10.01，根据官方文件得知放8天
  // TODO 优化此类问题的解决方式
  const Festival(
      dateString: '10.01-10.08',
      greetings: ['举国同庆🎉', '祖国母亲生日快乐🥳', '国旗飘扬心中🇨🇳', '愿祖国繁荣昌盛🌟']),

  // 中秋节：八月十五
  Festival(
      dateString: lunarToDateString(8, 15),
      greetings: ['中秋节快乐🥳', '月圆人团圆✨', '赏月吃月饼🥮']),

  // 万圣夜和万圣节：10.31-11.1
  const Festival(
      dateString: '10.31-11.1',
      greetings: ['Happy Halloween🎃', '不给糖就捣蛋👻🍬', '万圣节快乐👻😈']),

  // 圣诞节：12.25
  const Festival(
      dateString: '12.25',
      greetings: ['Merry Christmas🎄', '圣诞节快乐🎄', '圣诞老人带着礼物来啦🎁'])
];
