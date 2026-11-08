![Status](https://img.shields.io/badge/status-active%20development-orange) ![Game](https://img.shields.io/badge/Farming%20Simulator-25-green) ![Issues](https://img.shields.io/badge/issues-welcome-brightgreen)

[![Version](https://img.shields.io/badge/version-1.2.0.0-blue)](https://github.com/Dude23-mods/FS25_Personnel_Management/releases/download/v1.2.0.0/FS25_PersonnelManagement.zip)
# FS25_Personnel_Management
<p align="center"><img width="768" alt="personnel_management_picture" src="https://github.com/user-attachments/assets/0c5cb6b1-816c-4127-aa88-70e985e88fe1" /></p>

Personnel Management adds a persistent employee system to Farming Simulator 25. Instead of relying only on anonymous helpers, each farm can recruit, hire, develop and manage individual employees with their own names, salaries, experience, reliability, loyalty, specializations and career histories.

Version 1.2.0.0 introduces job interviews, a redesigned personnel interface, more varied applicant and employee profiles, and improvements to specialization progress tracking and multiplayer handling.

### Support 
[![Support me on Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20my%20work-ff5e5b?logo=ko-fi&logoColor=white)](https://ko-fi.com/dude23mods)

All of my mods are available completely free of charge. Nobody has to pay to download or use them. I do not intend to make a profit from my mods, nor do I expect donations to cover all of my development-related expenses.
Your support just helps me spending more time developing, testing and maintaining my mods. Thank you for supporting!

## Contents
- [Compatibility Notice](#compatibility-notice)
  - [AutoDrive and Courseplay](#autodrive-and-courseplay)
  - [FollowMe](#followme)
- [Features](#features)
  - [Personnel Management Menu](#personnel-management-menu)
  - [Employee Selection](#employee-selection)
  - [Applicant Market](#applicant-market)
  - [Job Interviews](#job-interviews)
  - [Employee Profiles and Career Histories](#employee-profiles-and-career-histories)
  - [Salaries and Salary Requests](#salaries-and-salary-requests)
  - [Experience and Ranks](#experience-and-ranks)
  - [Reliability](#reliability)
  - [Loyalty](#loyalty)
  - [Specializations](#specializations)
  - [Training](#training)
  - [Resignations, Dismissals and Retirement](#resignations-dismissals-and-retirement)
  - [Helper Assignment](#helper-assignment)
  - [Transport Priority Management](#transport-priority-management)
  - [Farm Overview and Statistics](#farm-overview-and-statistics)
  - [Gameplay Settings](#gameplay-settings)
  - [In-game Help](#in-game-help)
  - [Savegame Support](#savegame-support)
  - [Multiplayer Synchronization](#multiplayer-synchronization)
- [Planned Features](#planned-features)
- [Development Status](#development-status)

## Compatibility Notice

### AutoDrive and Courseplay
![AutoDrive](https://img.shields.io/badge/AutoDrive-supported-brightgreen)
![Courseplay](https://img.shields.io/badge/Courseplay-supported-brightgreen)

AutoDrive and Courseplay are supported by Personnel Management as of version 1.1.1.0. Employees can be assigned to jobs started by either mod, while Personnel Management tracks their availability, working time, wages and job status.

AutoDrive does not provide direct employee selection. Instead, it automatically assigns available employees who have been designated for transport tasks in the Personnel Management menu. Courseplay supports direct employee selection when starting a job.

Handoffs between AutoDrive and Courseplay are handled to prevent duplicate assignments and employees remaining incorrectly marked as busy. The integration includes support for AutoDrive 3.0.1.4 and Courseplay 8.1.0.3. If unexpected behavior occurs, please include the relevant log file and exact mod versions when reporting the issue.

### FollowMe
![FollowMe Supported](https://img.shields.io/badge/FollowMe-supported-brightgreen)

FollowMe has been supported since version 1.0.3.0. When a FollowMe job is started, Personnel Management opens its employee selection and requires an additional available employee for the following vehicle. The job is assigned to a real member of the farm's workforce instead of an unnamed native helper.

The assigned employee is shown in job messages and in the employee menu. FollowMe working time contributes to experience and specialization progress according to the detected activity. Pure following without a trailer or implement is treated as transport work, while suitable attached implements may be recognized as field work such as tillage, sowing, fertilizing, plant protection or harvesting.

## Features

### Personnel Management Menu

Open the standalone Personnel Management menu with **Ctrl+M**. Its redesigned interface combines the most important personnel functions:

- farm overview and monthly reports,
- applicant market,
- employee profiles,
- training management,
- gameplay and salary settings.

The menu includes detailed profile views, progress bars, career histories, status information and context-sensitive action buttons. Confirmation dialogs protect important actions such as dismissals and training starts, while page-specific input handling prevents hidden menu pages from reacting to the same key press.

### Employee Selection

When assigning a helper job, Personnel Management opens a dedicated employee selection window. It shows the employee portrait, performance profile, key statistics, learned specializations and professional development. 

### Applicant Market

Each farm has a persistent applicant market. Applicants are generated globally and may be offered to different farms depending on employer reputation. They remain available across save and load cycles and have individual:

- names and portraits,
- birthdays and ages,
- professional backgrounds,
- salary expectations,
- experience, reliability and loyalty values,
- specialization progress.

When interviews are enabled, attributes, rank and salary expectations are not all visible initially; see [Job Interviews](#job-interviews). Professional backgrounds influence starting experience and create more believable profiles. Applicants stay on the market for a limited period and may leave after later monthly transitions, so recruitment decisions cannot always be postponed indefinitely.

Applicant ages use a weighted distribution: 30% aged 18-29, 30% aged 30-39, 22% aged 40-49, 13% aged 50-59 and 5% aged 60-65.

### Job Interviews

When job interviews are enabled, an applicant's experience, reliability and loyalty are initially hidden, apart from a range for one of the three attributes. You can conduct one interview per applicant, with up to three questions about those attributes.

Ask about different attributes to reveal their ranges, or ask follow-up questions to narrow a range and eventually reveal its exact value. An interview can be interrupted and continued later. The applicant's salary expectation is revealed once the interview is complete; their rank becomes visible when their exact experience is known.

After hiring, attributes that are still unknown are revealed as the employee spends time on assignments; the time required varies from employee to employee. Interviews can be disabled in the settings, making applicant attributes visible immediately.

In multiplayer, other players on the same farm can follow an interview. The first authorized player to open the interview window takes charge of the conversation.

### Employee Profiles and Career Histories

Hired applicants become permanent employees of the farm and continue to develop over time. Their profiles include personal values, rank, salary, employment status, specializations and a written background. Applicant and employee profiles use a wider variety of text variants. Attributes that were not fully revealed during an interview remain partially hidden until the employee has spent enough time on assignments.

Important events are recorded in an individual career history, including hiring, training, salary decisions, assignment interruptions, dismissals, resignations and retirement-related events.

### Salaries and Salary Requests

Every employee receives an individual monthly salary. Salary adjustments remain persistent and are not overwritten at the next monthly transition.

Employees may submit salary increase requests. Open requests are managed centrally through the employee menu with **G**. The salary request window lists every employee currently waiting for a decision together with the current and requested monthly salary. Each request can be accepted or rejected individually.

Salary decisions can affect loyalty and long-term employment stability. The standard monthly salary for newly generated applicants can be configured in the settings menu.

### Experience and Ranks

Employees gain experience by completing helper work. Working time and recognized activities contribute to their development. Experience is displayed together with an employee rank, making long-term progression easier to assess.

Depending on the selected gameplay settings, experienced employees can provide gameplay benefits and become more valuable members of the workforce.

### Reliability

Reliability represents how dependable an employee is during daily work. Employees with low reliability may interrupt an active assignment. The job is then ended through the normal server-authoritative workflow, the employee becomes available again and the incident is added to the career history.

More reliable employees are less likely to interrupt assignments.

### Loyalty

Loyalty represents how satisfied an employee is with the farm. It can change through salary decisions, dismissals, employment events and other personnel-related developments.

Low loyalty can contribute to an employee deciding to leave the farm, while fair decisions and stable employment help maintain a reliable workforce.

### Specializations

Employees can make specialization progress through recognized activities during their assignments. They can learn more than two specializations over time, but no more than two specialization bonuses can be active simultaneously. Either active slot can be disabled without losing the learned specialization. A deactivated specialization can only be reactivated once per employee and agricultural year.

Recognized activities include field work, harvesting, transport and other supported helper tasks. Progress and completed specializations are shown in the personnel menu. The tracking of specialization progress has been improved to account for short assignments and fractions of minutes. Activity recognition continues to be improved; not every combination of equipment and mods can be detected perfectly.

### Training

Employees can attend training to improve their progress in a selected specialization. The training menu shows available categories, current progress, costs, temporary price adjustments and whether learned specializations are active or inactive.

Training offers can change from month to month. Individual categories may temporarily have no available places, and an employee can complete only one training course per agricultural year from March to February. Training begins at the start of a month and the employee remains unavailable until the training period is complete.

Training availability and specialization activation are separate rules. An employee can complete only one training course per agricultural year. A learned deactivated specialization can also be reactivated only once per agricultural year.

### Resignations, Dismissals and Retirement

Employees may resign, can be dismissed by an authorized farm manager and may retire as they grow older.

Dismissals and resignations follow notice-period rules instead of always removing the employee immediately. Affected employees generally remain part of the workforce until the applicable monthly transition. Retirement is announced in advance and is based on an individually stored retirement profile whose probability increases with age.

Confirmation dialogs are used for important personnel decisions to reduce accidental actions.

### Helper Assignment

Personnel Management extends the native helper system by assigning real employees from the farm's workforce to supported AI jobs. Only employees who are currently available can be selected.

The selected employee appears in job messages and gains working time, experience and specialization progress from the assignment. Multiple employees can work at the same time, and FollowMe jobs use the same personnel system.

### Transport Priority Management

The employee menu contains a dedicated transport management window, opened with **T**. It lists active transport drivers in priority order and inactive employees separately.

Farm managers can:

- activate or deactivate employees for transport assignments,
- move active drivers up or down in the priority order,
- save or discard the complete transport configuration.

When a transport employee is needed, the mod selects available drivers according to this stored priority order.

### Farm Overview and Statistics

The overview page combines the current monthly personnel report with long-term farm statistics. It includes values such as working time, completed assignments, salary costs and workforce changes.

Long-term totals track employees who have been hired, dismissed, resigned or retired, providing a clearer picture of personnel development across the savegame.

### Gameplay Settings

The settings page groups options for work performance, personnel development, economic effects, salaries and job interviews. The standard monthly salary can be entered directly and is stored through the existing configuration system.

Settings are farm-specific where required and are synchronized through the multiplayer workflow.

### In-game Help

Personnel Management includes a complete in-game Help section with the same subject matter as the ReadMe. The Help uses a topic list and article view inspired by the Precision Farming layout. German is used for the German game language, French for French, and English for all other languages.

### Savegame Support

Personnel data persists across save and load cycles, including applicant markets, interview progress, employee profiles, career histories, salaries, training, specialization progress, active specialization slots, specialization activation years, transport priorities, statistics and farm-specific settings. Existing savegames can still be carried over.

### Multiplayer Synchronization

Personnel Management uses farm-scoped multiplayer synchronization. Applicants, interview progress, employees, settings, training, salary requests, transport priorities and personnel statistics are synchronized between server and clients.

Personnel actions are server-authoritative. Clients may display the interface and send requests, but the server validates the farm, target employee, current state and farm-manager permission before applying actions such as hiring, dismissing, training, salary decisions or transport-priority changes.

This prevents players from modifying another farm's personnel and preserves consistent savegame state in multiplayer and dedicated-server environments.

## Planned Features

- Introduction of a new employee type: Apprentice
- Salary negotiations
- A more transparent employer reputation system

This is deliberately not intended to be a roadmap, but rather a brainstorming list of possible future features. Whether and how any of these ideas will be implemented remains undecided.

## Development Status

Personnel Management is under active development. Multiplayer, dedicated-server behavior, savegame migration and compatibility with other mods are tested and improved continuously, but not every possible mod combination can be covered.

The new and revised texts are available in all supported languages. Translations were created with the help of AI and have not yet been fully reviewed.

Please report reproducible bugs, compatibility problems or unexpected behavior through GitHub Issues. Logs, screenshots, savegame details and exact reproduction steps are especially helpful.
