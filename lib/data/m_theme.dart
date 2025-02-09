import 'package:flutter/material.dart';
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

  static const hovered = Color.fromRGBO(216, 229, 235, 1);

  static const radius = 16.0;

  static final theme = FThemes.zinc.light;

  static get themeData {
    final borderRadius = BorderRadius.circular(radius);
    final tileStyle = theme.tileGroupStyle.tileStyle.copyWith(
      border: Border.all(color: border),
      focusedBorder: Border.all(color: primary3),
      borderRadius: borderRadius,
      enabledBackgroundColor: Colors.white,
      enabledHoveredBackgroundColor: hovered,
    );
    final tileGroupStyle = theme.tileGroupStyle.copyWith(
      borderColor: MTheme.border,
      borderRadius: borderRadius,
      tileStyle: tileStyle,
    );

    return FThemeData(
      colorScheme: theme.colorScheme.copyWith(
        border: border,
      ),
      typography: theme.typography.copyWith(
        base: theme.typography.base.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: theme.style.copyWith(
        focusedOutlineStyle: theme.style.focusedOutlineStyle
            .copyWith(color: border, borderRadius: borderRadius),
        borderRadius: borderRadius,
      ),
      accordionStyle: theme.accordionStyle,
      alertStyles: theme.alertStyles,
      avatarStyle: theme.avatarStyle,
      badgeStyles: theme.badgeStyles,
      bottomNavigationBarStyle: theme.bottomNavigationBarStyle,
      breadcrumbStyle: theme.breadcrumbStyle,
      buttonStyles: theme.buttonStyles.copyWith(
        primary: theme.buttonStyles.primary.copyWith(
          enabledBoxDecoration:
              theme.buttonStyles.primary.enabledBoxDecoration.copyWith(
            color: primary2,
            borderRadius: borderRadius,
          ),
          enabledHoverBoxDecoration:
              theme.buttonStyles.primary.enabledHoverBoxDecoration.copyWith(
            color: hovered,
            borderRadius: borderRadius,
          ),
          disabledBoxDecoration:
              theme.buttonStyles.primary.disabledBoxDecoration.copyWith(
            color: disabled,
            borderRadius: borderRadius,
          ),
        ),
        outline: theme.buttonStyles.outline.copyWith(
          enabledBoxDecoration:
              theme.buttonStyles.outline.enabledBoxDecoration.copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
          ),
          enabledHoverBoxDecoration:
              theme.buttonStyles.outline.enabledHoverBoxDecoration.copyWith(
            color: border.withDarkness(0.1),
            borderRadius: borderRadius,
          ),
          disabledBoxDecoration:
              theme.buttonStyles.outline.disabledBoxDecoration.copyWith(
            border: Border.all(color: disabled),
            borderRadius: borderRadius,
          ),
        ),
      ),
      calendarStyle: theme.calendarStyle,
      cardStyle: theme.cardStyle,
      checkboxStyle: theme.checkboxStyle.copyWith(
        enabledStyle: theme.checkboxStyle.enabledStyle.copyWith(
          borderColor: primary2,
          checkedBackgroundColor: primary2,
        ),
        disabledStyle: theme.checkboxStyle.disabledStyle.copyWith(
          borderColor: disabled,
          checkedBackgroundColor: disabled,
        ),
      ),
      datePickerStyle: theme.datePickerStyle,
      dialogStyle: theme.dialogStyle,
      dividerStyles: theme.dividerStyles,
      headerStyle: theme.headerStyle,
      labelStyles: theme.labelStyles,
      lineCalendarStyle: theme.lineCalendarStyle.copyWith(
        selectedItemStyle: theme.lineCalendarStyle.selectedItemStyle.copyWith(
          todayIndicatorColor: Colors.white,
          decoration:
              theme.lineCalendarStyle.selectedItemStyle.decoration.copyWith(
            borderRadius: borderRadius,
            color: primary2,
          ),
          focusedDecoration: theme
              .lineCalendarStyle.selectedItemStyle.focusedDecoration
              .copyWith(
            borderRadius: borderRadius,
            color: primary2,
          ),
        ),
        selectedHoveredItemStyle:
            theme.lineCalendarStyle.selectedHoveredItemStyle.copyWith(
          todayIndicatorColor: Colors.white,
          decoration: theme
              .lineCalendarStyle.selectedHoveredItemStyle.decoration
              .copyWith(
            borderRadius: borderRadius,
            color: hovered,
          ),
          focusedDecoration: theme
              .lineCalendarStyle.selectedHoveredItemStyle.focusedDecoration
              .copyWith(
            borderRadius: borderRadius,
            color: hovered,
          ),
        ),
        unselectedItemStyle:
            theme.lineCalendarStyle.unselectedItemStyle.copyWith(
          todayIndicatorColor: primary2,
          decoration:
              theme.lineCalendarStyle.unselectedItemStyle.decoration.copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
          ),
          focusedDecoration: theme
              .lineCalendarStyle.unselectedItemStyle.focusedDecoration
              .copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
          ),
        ),
        unselectedHoveredItemStyle:
            theme.lineCalendarStyle.unselectedHoveredItemStyle.copyWith(
          todayIndicatorColor: primary2,
          decoration: theme
              .lineCalendarStyle.unselectedHoveredItemStyle.decoration
              .copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
            color: hovered,
          ),
          focusedDecoration: theme
              .lineCalendarStyle.unselectedHoveredItemStyle.focusedDecoration
              .copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
            color: hovered,
          ),
        ),
      ),
      pickerStyle: theme.pickerStyle,
      popoverStyle: theme.popoverStyle,
      popoverMenuStyle: theme.popoverMenuStyle,
      progressStyle: theme.progressStyle,
      radioStyle: theme.radioStyle,
      resizableStyle: theme.resizableStyle,
      scaffoldStyle: theme.scaffoldStyle,
      selectGroupStyle: theme.selectGroupStyle,
      selectMenuTileStyle: theme.selectMenuTileStyle.copyWith(
        tileStyle: tileStyle,
        menuStyle: theme.selectMenuTileStyle.menuStyle.copyWith(
          decoration: theme.selectMenuTileStyle.menuStyle.decoration.copyWith(
            border: Border.all(color: border),
            borderRadius: borderRadius,
          ),
          tileGroupStyle: tileGroupStyle,
        ),
      ),
      sheetStyle: theme.sheetStyle,
      sliderStyles: theme.sliderStyles,
      switchStyle: theme.switchStyle,
      tabsStyle: theme.tabsStyle.copyWith(
        decoration: theme.tabsStyle.decoration.copyWith(
          color: Colors.white,
          border: Border.all(color: Colors.transparent, width: 0.0),
        ),
        indicatorDecoration:
            theme.tabsStyle.indicatorDecoration.copyWith(color: primary2),
        selectedLabelTextStyle: theme.tabsStyle.selectedLabelTextStyle.copyWith(
          color: Colors.white,
        ),
      ),
      textFieldStyle: theme.textFieldStyle.copyWith(
        cursorColor: primary1,
        enabledStyle: theme.textFieldStyle.enabledStyle.copyWith(
          unfocusedStyle:
              theme.textFieldStyle.enabledStyle.unfocusedStyle.copyWith(
            color: border,
            radius: borderRadius,
          ),
          focusedStyle:
              theme.textFieldStyle.enabledStyle.unfocusedStyle.copyWith(
            color: primary1,
            radius: borderRadius,
          ),
        ),
        disabledStyle: theme.textFieldStyle.disabledStyle.copyWith(
          unfocusedStyle:
              theme.textFieldStyle.disabledStyle.unfocusedStyle.copyWith(
            color: border.withDarkness(0.1),
            radius: borderRadius,
          ),
          focusedStyle:
              theme.textFieldStyle.disabledStyle.unfocusedStyle.copyWith(
            color: primary1.withDarkness(0.1),
            radius: borderRadius,
          ),
        ),
        errorStyle: theme.textFieldStyle.errorStyle.copyWith(
          unfocusedStyle:
              theme.textFieldStyle.errorStyle.unfocusedStyle.copyWith(
            radius: borderRadius,
          ),
          focusedStyle: theme.textFieldStyle.errorStyle.unfocusedStyle.copyWith(
            radius: borderRadius,
          ),
        ),
      ),
      tooltipStyle: theme.tooltipStyle,
      tileGroupStyle: tileGroupStyle,
    );
  }
}
