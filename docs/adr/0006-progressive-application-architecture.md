# 应用分层随项目规模逐步引入

教程采用 Flutter 官方应用架构中的 View、ViewModel、Repository、Service 和单向数据流，但只在状态与业务复杂度需要时逐步引入，复杂业务才增加领域层。小项目不预先套用 Clean Architecture 或 DDD；教程先让读者看见状态所有权、依赖替换和测试问题，再给出相应分层。
