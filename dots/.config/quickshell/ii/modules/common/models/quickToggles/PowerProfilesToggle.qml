import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Power Profile")
    toggled: CpuModeService.isCustomActive
    icon: CpuModeService.icon
    statusText: CpuModeService.statusText
    
    mainAction: () => {
        CpuModeService.cycle();
    }
    tooltipText: Translation.tr("CPU Mode: ") + CpuModeService.statusText
}
