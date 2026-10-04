import SwiftUI

/// "我的"：工具入口 + 规划中的进阶功能路线图
struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("工具") {
                    NavigationLink {
                        TagManagementView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "tag")
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("标签管理")
                                Text("查看、重命名、合并、删除标签")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("即将上线") {
                    UpcomingRow(icon: "heart.text.square", title: "心愿单", subtitle: "记录想买的东西，估算日均成本")
                    UpcomingRow(icon: "icloud", title: "iCloud 同步", subtitle: "多设备自动同步资产数据")
                    UpcomingRow(icon: "square.and.arrow.up", title: "数据导出", subtitle: "导出资产报告 PDF / 表格")
                    UpcomingRow(icon: "crown", title: "会员订阅", subtitle: "内购解锁高级功能")
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("0.2.0（MVP）").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
}

private struct UpcomingRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("敬请期待").font(.caption2).foregroundStyle(.secondary)
        }
    }
}
