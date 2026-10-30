package com.bookstore.controller.report;

import com.bookstore.entity.branch.Branch;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.report.AgingStockReportDTO;
import com.bookstore.service.report.BranchPerformanceReportDTO;
import com.bookstore.service.report.ReportService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/admin/reports")
public class ReportAdminController {

    private final ReportService reportService;
    private final BranchRepository branchRepository;

    public ReportAdminController(ReportService reportService, BranchRepository branchRepository) {
        this.reportService = reportService;
        this.branchRepository = branchRepository;
    }

    @GetMapping
    public String showReports(
            @RequestParam(required = false) Long branchId,
            @RequestParam(defaultValue = "90") int thresholdDays,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        Long targetBranch = branchId;
        if (!SecurityUtils.isSuperAdmin()) {
            targetBranch = (userDetails != null) ? userDetails.getBranchId() : null;
        }

        List<BranchPerformanceReportDTO> performanceReports = reportService.getBranchPerformanceReports(targetBranch);
        List<AgingStockReportDTO> agingStock = reportService.getAgingStockReport(targetBranch, thresholdDays);

        model.addAttribute("performanceReports", performanceReports);
        model.addAttribute("agingStock", agingStock);
        model.addAttribute("targetBranch", targetBranch);
        model.addAttribute("thresholdDays", thresholdDays);
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());
        model.addAttribute("branches", branchRepository.findAll());

        return "admin/reports";
    }
}
