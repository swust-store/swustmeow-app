import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/color.dart';

class MTheme {
  static const primary1 = Color.fromRGBO(14, 78, 145, 1);

  static const primary2 = Color.fromRGBO(27, 122, 222, 1);

  static const primary3 = Color.fromRGBO(61, 181, 255, 1);

  static const primary4 = Color.fromRGBO(167, 223, 243, 1);

  static const disabled = Color.fromRGBO(167, 203, 217, 1);

  static const primaryText = Color.fromRGBO(167, 223, 243, 1);

  static const border = Color.fromRGBO(193, 218, 227, 1);

  static final theme = FThemes.zinc.light;

  static final themeData = FThemeData(
    colorScheme: theme.colorScheme.copyWith(
      border: border,
    ),
    typography: theme.typography.copyWith(
      base: theme.typography.base.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    style: theme.style.copyWith(
      focusedOutlineStyle: theme.style.focusedOutlineStyle.copyWith(
        color: border,
      ),
    ),
    accordionStyle: theme.accordionStyle,
    alertStyles: theme.alertStyles,
    avatarStyle: theme.avatarStyle,
    badgeStyles: theme.badgeStyles,
    bottomNavigationBarStyle: theme.bottomNavigationBarStyle,
    breadcrumbStyle: theme.breadcrumbStyle,
    buttonStyles: theme.buttonStyles.copyWith(
      primary: theme.buttonStyles.primary.copyWith(
        enabledBoxDecoration: theme.buttonStyles.primary.enabledBoxDecoration
            .copyWith(color: primary2),
        enabledHoverBoxDecoration: theme
            .buttonStyles.primary.enabledHoverBoxDecoration
            .copyWith(color: primary2.withDarkness(0.1)),
        disabledBoxDecoration: theme.buttonStyles.primary.disabledBoxDecoration
            .copyWith(color: disabled),
      ),
      outline: theme.buttonStyles.outline.copyWith(
        enabledBoxDecoration: theme.buttonStyles.outline.enabledBoxDecoration
            .copyWith(border: Border.all(color: border)),
        enabledHoverBoxDecoration: theme
            .buttonStyles.outline.enabledHoverBoxDecoration
            .copyWith(color: border.withDarkness(0.1)),
        disabledBoxDecoration: theme.buttonStyles.outline.disabledBoxDecoration
            .copyWith(border: Border.all(color: disabled)),
      ),
    ),
    calendarStyle: theme.calendarStyle,
    cardStyle: theme.cardStyle,
    checkboxStyle: theme.checkboxStyle,
    datePickerStyle: theme.datePickerStyle,
    dialogStyle: theme.dialogStyle,
    dividerStyles: theme.dividerStyles,
    headerStyle: theme.headerStyle,
    labelStyles: theme.labelStyles,
    lineCalendarStyle: theme.lineCalendarStyle,
    pickerStyle: theme.pickerStyle,
    popoverStyle: theme.popoverStyle,
    popoverMenuStyle: theme.popoverMenuStyle,
    progressStyle: theme.progressStyle,
    radioStyle: theme.radioStyle,
    resizableStyle: theme.resizableStyle,
    scaffoldStyle: theme.scaffoldStyle,
    selectGroupStyle: theme.selectGroupStyle,
    selectMenuTileStyle: theme.selectMenuTileStyle,
    sheetStyle: theme.sheetStyle,
    sliderStyles: theme.sliderStyles,
    switchStyle: theme.switchStyle,
    tabsStyle: theme.tabsStyle,
    textFieldStyle: theme.textFieldStyle.copyWith(
      cursorColor: primary1,
      enabledStyle: theme.textFieldStyle.enabledStyle.copyWith(
        unfocusedStyle: theme.textFieldStyle.enabledStyle.unfocusedStyle
            .copyWith(color: border),
        focusedStyle: theme.textFieldStyle.enabledStyle.unfocusedStyle
            .copyWith(color: primary1),
      ),
      disabledStyle: theme.textFieldStyle.disabledStyle.copyWith(
        unfocusedStyle: theme.textFieldStyle.disabledStyle.unfocusedStyle
            .copyWith(color: border.withDarkness(0.1)),
        focusedStyle: theme.textFieldStyle.disabledStyle.unfocusedStyle
            .copyWith(color: primary1.withDarkness(0.1)),
      ),
    ),
    tooltipStyle: theme.tooltipStyle,
    tileGroupStyle: theme.tileGroupStyle,
  );
}
