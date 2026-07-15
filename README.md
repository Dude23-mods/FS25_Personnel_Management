![Status](https://img.shields.io/badge/status-active%20development-orange) ![Version](https://img.shields.io/badge/version-1.1.0.0-blue) ![Game](https://img.shields.io/badge/Farming%20Simulator-25-green) ![Issues](https://img.shields.io/badge/issues-welcome-brightgreen)
# FS25_Personnel_Management
<p align="center"><img width="768" alt="personnel_management_picture" src="https://github.com/user-attachments/assets/0c5cb6b1-816c-4127-aa88-70e985e88fe1" /></p>

Personnel Management adds a persistent employee system to Farming Simulator 25. Instead of relying only on anonymous helpers, each farm can recruit, hire, develop and manage individual employees with their own names, salaries, experience, reliability, loyalty, specializations and career histories.

Version 1.1.0.0 introduces a standalone Personnel Management menu, a persistent and more dynamic applicant market, expanded employee development, centralized salary request management, transport-driver priorities, retirement and long-term farm statistics.

## Contents
- [Compatibility Notice](#compatibility-notice)
  - [AutoDrive and Courseplay](#autodrive-and-courseplay)
  - [FollowMe](#followme)
- [Features](#features)
  - [Personnel Management Menu](#personnel-management-menu)
  - [Applicant Market](#applicant-market)
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
  - [Savegame Support](#savegame-support)
  - [Multiplayer Synchronization](#multiplayer-synchronization)
- [Development Status](#development-status)

## Compatibility Notice

### AutoDrive and Courseplay
![AutoDrive](https://img.shields.io/badge/AutoDrive-not%20supported-red)
![Courseplay](https://img.shields.io/badge/Courseplay-not%20supported-red)

AutoDrive and Courseplay are currently not supported by Personnel Management. These mods use their own AI and automation systems, which are not fully compatible with the way Personnel Management assigns and manages employees for helper jobs. Using AutoDrive or Courseplay together with this mod may lead to incorrect helper assignment, native GIANTS helpers being used instead of employees, Lua errors or performance issues. For stable gameplay, it is recommended to disable AutoDrive and Courseplay when using Personnel Management.

### FollowMe
![FollowMe Supported](https://img.shields.io/badge/FollowMe-supported-brightgreen)

FollowMe has been supported since version 1.0.3.0. When a FollowMe job is started, Personnel Management opens its employee selection and requires an additional available employee for the following vehicle. The job is assigned to a real member of the farm's workforce instead of an unnamed native helper.

The assigned employee is shown in job messages and in the employee menu. FollowMe working time contributes to experience and specialization progress according to the detected activity. Pure following without a trailer or implement is treated as transport work, while suitable attached implements may be recognized as field work such as tillage, sowing, fertilizing, plant protection or harvesting.

## Features

### Personnel Management Menu

Version 1.1.0.0 adds a standalone Personnel Management menu that can be opened with **Ctrl+M**. It combines the most important personnel functions in one interface:

- farm overview and monthly reports,
- applicant market,
- employee profiles,
- training management,
- gameplay and salary settings.

The menu includes detailed profile views, progress bars, career histories, status information and context-sensitive action buttons. Confirmation dialogs protect important actions such as dismissals and training starts, while page-specific input handling prevents hidden menu pages from reacting to the same key press.

### Applicant Market

Each farm has its own persistent applicant market. Applicants remain available across save and load cycles and have individual:

- names and portraits,
- birthdays and ages,
- professional backgrounds,
- salary expectations,
- experience, reliability and loyalty values,
- specialization progress.

Professional backgrounds influence starting experience and create more believable profiles. Applicants stay on the market for a limited period and may leave after later monthly transitions, so recruitment decisions cannot always be postponed indefinitely.

### Employee Profiles and Career Histories

Hired applicants become permanent employees of the farm and continue to develop over time. Their profiles include personal values, rank, salary, employment status, specializations and a written background.

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

Employees learn specializations through the work they actually perform. Progress can develop in several activity categories at the same time, and an employee can ultimately acquire up to two specializations.

Recognized activities include field work, harvesting, transport and other supported helper tasks. Progress and completed specializations are shown in the personnel menu.

### Training

Employees can attend training to improve selected attributes and specialization progress. The training menu shows available categories, current progress, costs and temporary price adjustments.

Training offers can change from month to month. Individual categories may temporarily have no available places, and an employee can complete only one training course per agricultural year from March to February. Training begins at the start of a month and the employee remains unavailable until the training period is complete.

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

The settings page groups options for work performance, personnel development, economic effects and salaries. The standard monthly salary can be entered directly and is stored through the existing configuration system.

Settings are farm-specific where required and are synchronized through the multiplayer workflow.

### Savegame Support

Personnel data is stored with the savegame and restored when the game is loaded. Version 1.1.0.0 persists substantially more information, including:

- farm-specific applicant markets,
- employee profiles and career histories,
- birthdays, age and retirement data,
- salaries and open salary requests,
- specialization and training progress,
- transport-driver status and priority,
- long-term personnel statistics and settings.

Existing savegames from earlier mod versions are migrated where necessary. Missing values are initialized without replacing established employees or applicant data.

### Multiplayer Synchronization

Personnel Management uses farm-scoped multiplayer synchronization. Applicants, employees, settings, training, salary requests, transport priorities and personnel statistics are synchronized between server and clients.

Personnel actions are server-authoritative. Clients may display the interface and send requests, but the server validates the farm, target employee, current state and farm-manager permission before applying actions such as hiring, dismissing, training, salary decisions or transport-priority changes.

This prevents players from modifying another farm's personnel and preserves consistent savegame state in multiplayer and dedicated-server environments.

## Development Status

Personnel Management is under active development. Multiplayer, dedicated-server behavior, savegame migration and compatibility with other AI-related mods are tested and improved continuously, but not every possible mod combination can be covered.

Please report reproducible bugs, compatibility problems or unexpected behavior through GitHub Issues. Logs, screenshots, savegame details and exact reproduction steps are especially helpful.
