# Zarb-Ul-Hadeed (117 SP Regt.) — Military Roster Console

A high-performance, premium Flutter administration console and personnel tracking dashboard designed for military unit deployment. This document provides a comprehensive blueprint of the system's design patterns, visual theme, user interfaces, functional modules, and security architectures to assist developers in building a matching web application or desktop client.

---

## 1. Visual Identity & Design System

The application utilizes a premium military design language featuring **Glassmorphism**, neon highlights, sleek golds, and deep regimental forest greens. 

### A. Color Palette Reference

| Palette Token | Light Mode Value | Dark Mode Value | Semantic Role |
| :--- | :--- | :--- | :--- |
| **Forest Green (Primary)** | `#0C5A32` | `#0C5A32` | Header background, primary buttons, positive labels |
| **Deep Forest (Background)**| `#E8F5EE` | `#03140A` | Scaffold background, login background, input backdrops |
| **Gold Metallic (Accent)**  | `#9E7715` | `#CD9B2D` | High-contrast borders, category titles, active states |
| **Neon Green (Highlight)** | `#0C5A32` (Muted) | `#00FF66` | Online state badges, statistics badges, focus indicator |
| **Gold Highlight (Text)**  | `#4A5D52` | `#FFF2C2` | Golden header typography gradients |
| **Body Typography (Light)**| `#042011` | `#FFFFFF` | Primary reading text |
| **Body Typography (Muted)**| `#4A5D52` | `#E5E5E5` | Labels, details, descriptions, subtitles |
| **Danger Muted (Delete)**  | `#FFD2D2` | `#FF1F1F` (Muted) | Alert cards, delete button background |
| **Danger Highlight**       | `#D32F2F` | `#FF5252` | Delete button labels, invalid warning icons |

### B. UI Styling Tokens
* **Border Radius**: Consistent `12px` to `16px` rounded corners on all cards, text inputs, and dialog boxes.
* **Glassmorphism**: App bars and bottom navigation bars use a semi-translucent backdrop filter with a blur factor of `sigmaX: 10, sigmaY: 10` and `85% opacity`.
* **Elevations & Borders**: Flat design in dark mode with thin `1px` high-contrast gold outlines (`alpha: 0.25`). Light mode utilizes soft shadows (`blurRadius: 10, offset: (0, 4)`) combined with forest green borders.

---

## 2. Authentication & Role-Based Access Control (RBAC)

The console implements three user roles. Session management is tracked via the `MockDataManager` singleton class.

```
┌─────────────────┐     Logs In     ┌───────────────────────────┐
│     User Type   ├────────────────►│      Assigned Access      │
└─────────────────┘                 └───────────────────────────┘
│ [superadmin]    │ ──────────────► │ Full Admin CRUD + Settings│
│ [admin / Roster]│ ──────────────► │ Read + Edit Locations     │
│ [user]          │ ──────────────► │ View-Only (3 Tabs)        │
└─────────────────┘                 └───────────────────────────┘
```

### Roles and Permissions Mapping

1. **`superadmin`** (System Administrator)
   * Username: `superadmin` (plus custom usernames promoted by superadmin)
   * Default Password: `123456`
   * Permissions:
     * Full access to all 5 navigation tabs.
     * View, edit, add, rename, and delete collapsible categories/subcategories.
     * View, add, edit, and delete personnel records.
     * Assign locations, statuses, and date periods.
     * Access the Admin Accounts settings tab to create, edit, or delete credentials.

2. **`admin`** (Data Entry Administrator)
   * Username: `admin` (or custom promoted soldier accounts created by superadmin)
   * Default Password: `123456`
   * Permissions:
     * Access to 5 navigation tabs.
     * View roster and location assignments.
     * Edit/Assign locations and dates for soldiers (via the Edit Tab).
     * Cannot access speed dial FAB buttons (no permission to add/delete categories or add/delete personnel).
     * Cannot access the Admin Accounts list in the settings tab (can only update their own username/password).

3. **`user`** (View-Only User)
   * Username: `user`
   * Default Password: `123456`
   * Permissions:
     * Access restricted to **4 tabs** (Dashboard, Analysis, Nominal Roll, Settings). The "Edit" tab is completely hidden.
     * Read-only access to all categories, numbers, statistics, and nominal roll files.
     * Settings tab is restricted to Theme Selection and Mobile Instructions.

---

## 3. Screen Specifications & UI Component Breakdown

### A. Login & Splash Screen (Forced Dark Theme)
To maintain a premium military presentation, the login form is styled exclusively in **Dark Mode** regardless of the globally selected system theme.

#### Interface Components:
* **Background Canvas**: Dark topographic green landscape paint with a centered gold regimental shield asset (`army_crest.jpg`).
* **Title Header**: Double-layered typography: `ZARB-UL-HADEED` in a gradient gold mask (`#FFF2C2` to `#E9C54F`), sub-header `117 SP REGT.` in white.
* **Username Field**: 
  - Input Type: Plain Text Controller (case-insensitive checks).
  - Design: Rounded borders, prefix user icon, gold focus border.
* **Password Field**:
  - Input Type: Obscured/Secret Text Input.
  - Design: Prefix lock icon, gold focus border.
* **Login Button**: Full-width forest green button (`#0C5A32`) with gold borders, uppercase white text.

---

### B. Dashboard Screen (Tab 1)
Displays collapsible, multi-layered hierarchies of locations, tasks, and duties along with active headcounts.

#### Interface Components:
* **Collapsible Status Roster (Tree View)**:
  - Displays Category Accordions (e.g., *Present*, *Leave*, *Courses*, *Att*).
  - Tapping a header expands/collapses nested subcategories (e.g., *Leave* -> *Casual Leave*, *Privilege Leave*) and sub-subcategories (e.g., *Casual Leave* -> *In Station*, *Out Station*).
  - Accompanying numeric badges display active headcounts inside the category.
* **Active Status List**:
  - Displays cards of soldiers currently assigned to the selected category.
  - Double-tap or long-press opens their **Military ID Card Modal**.
* **Floating Action Menu (Speed Dial FAB - Superadmin Only)**:
  - Main trigger gold circular menu button (`Icons.menu_rounded` -> rotating to `Icons.close_rounded` on open).
  - Sub-FAB 1 (Plus Icon): Opens the **Add Category Dialog** (allows adding category, subcategory, and sub-subcategory).
  - Sub-FAB 2 (Edit/Pencil Icon): Opens the **Edit Category Dialog** (allows renaming).
  - Sub-FAB 3 (Trash Icon): Opens the **Delete Category Dialog** (removes selected category).

---

### C. Analysis Screen (Tab 2)
Provides visual metrics, headcounts, percentages, and battery/trade/rank breakdowns for regimental strength distribution. Features a powerful drill-down system so commanders can inspect any sub-group in detail.

#### Interface Components:

**1. Analysis Mode Tabs**
Three segmented tabs at the top switch the entire analysis view:
- **Rank Analysis** — Breakdown by Officers, JCOs, Soldiers
- **Trade Analysis** — Breakdown by trade (Gnr, TA, OCU, DMT, DSV, Svy, Clk, Ck, NCB, SW, Engr, N/A, LAD)
- **Battery Analysis** — Breakdown by battery (HQ Bty, P Bty, Q Bty, R Bty)

**2. Smart Context-Aware Filter Dropdown**
Below the mode tabs, a single filter dropdown appears that changes dynamically based on the active mode:
- **Battery mode** → `Select Battery` dropdown (HQ Bty / P Bty / Q Bty / R Bty)
- **Trade mode** → `Select Trade` dropdown (all trades)
- **Rank mode** → `Select Rank` dropdown (Officers / JCOs / Soldiers)

A header label `FILTER: <active value>` shows the current selection. A `Reset` button appears whenever a filter is active.

The filter is **mode-aware**: selecting Trade=DMT only affects Trade analysis; switching to Battery mode uses Battery filter independently.

**3. Summary Bar**
Displays live-updated counts for the currently filtered dataset:
- `Bty / Trade / Rank Total`, `Fighting`, `Non Fighting`

**4. Battery Analysis Cards — Smart Grid**
- **All selected**: 2×2 grid of all 4 battery cards (HQ / P / Q / R)
- **Specific battery selected**: Only that one battery card is shown full-width; the other 3 are hidden
- Each card shows: Officers, JCOs, Sldrs, Non-Fighting counts, Fighting Ratio with a progress bar

**5. Fighting & Non-Fighting Parade State Panels**
Two expandable panels below the analysis cards:
- **OFFRS/JCOs/SLDRS** — Fighting group parade states
- **CLK/CK/NCBs/ENGRS, ETC.** — Non-fighting group parade states

Each panel shows Wrap chips of active parade categories with counts (e.g. `• Present: 4`, `• Leave: 6`).

**6. Drill-Down: Status → Filtered Personnel List**
Tapping any chip (e.g. `Present: 4`) opens `CategoryPersonnelListScreen` with intelligent pre-filtering:
- **Source list**: Only the personnel already visible after the active analysis filter (e.g. DMT trade)
- **Group context**: Fighting panel → only Fighting personnel; Non-Fighting panel → only Non-Fighting personnel
- **AppBar title**: Shows full context — e.g. `Fighting · Present · 4 Pers`

**7. CategoryPersonnelListScreen — Pre-selected & Smart Disabled Dropdowns**
When opened from the analysis screen, the in-screen filter dropdowns are automatically configured:
- The **active analysis filter is pre-selected** (e.g. Trade dropdown shows `DMT` by default)
- Dropdown items **not present** in the current filtered data are **greyed-out and disabled**, preventing invalid filter combinations
- Four dropdown filters: `Div` (All / Fighting / Non-Fighting), `Battery`, `Rank`, `Trade`
- Full-text search by Name or Army Number

---

### D. Nominal Roll Screen (Tab 3)
The master database directory of all soldiers in the regiment.

#### Interface Components:
* **Advanced Filters Section**:
  - Text input for keyword search (Name, Army Number, Rank).
  - Dropdown menu filters: **Battery Group** (*All*, *HQ*, *180*, *181*, *182*, *LAD*).
  - Segmented toggle filters: **Division Type** (*All*, *Fighting*, *Non-Fighting*).
* **Master Roster Renders**:
  - Scrollable lists of personnel cards matching active filters.
  - Tapping a card displays the soldier's **Military ID Card Modal**.
* **Military ID Card Modal**:
  - Renders a premium military ID containing: Full Name, Rank, Trade, Class, Phone Number, City of Residence, Division (Fighting/Non-Fighting), Current Location Category, and Assignment Period (Start Date to End Date).
* **Floating Action Menu (Speed Dial FAB - Superadmin Only)**:
  - Sub-FAB 1 (Plus Icon): Opens **Add Soldier Form**.
  - Sub-FAB 2 (Pencil Icon): Toggles **Edit Mode** (reveals edit sliders on list cards).
  - Sub-FAB 3 (Trash Icon): Toggles **Delete Mode** (reveals red delete indicators on list cards).

---

### E. Edit Assignments Screen (Tab 4)
The location/duty scheduler panel. Restricted to `superadmin` and `admin` roles.

#### Interface Components:
* **Roster Searcher**: Search bar to locate a soldier by Name, Rank, or Army Number.
* **Location Classification Pickers**:
  - Category Dropdown (All categories dynamically parsed from DB).
  - Subcategory Dropdown (Populates based on chosen parent).
  - Sub-Subcategory Dropdown (Populates if sub-sub-levels exist).
* **Duty Date Range Selectors**:
  - **Start Date Selector**: Styled calendar button (defaults to current date).
  - **End Date Selector**: Calendar picker button. Defaults to **`Infinite`** (indefinite duty).
  - **Set Infinite Toggle**: An underlined link (`Set Infinite`) that appears when a date is selected, resetting the assignment back to indefinite (null).
* **Action Button**: "SAVE ASSIGNMENT" (writes changes instantly to storage).

---

### F. Settings Center Screen (Tab 5)
Provides system parameters, guide tutorials, and user account management.

#### Interface Components:
* **Theme Card**: `SwitchListTile` to toggle Dark Mode / Light Mode globally.
* **Instructions Card**: `ListTile` triggering a modal showing instructions on category nesting, double-taps for ID cards, location updates, and sessions.
* **Regimental Card**: Muted regimental console branding and app version info.
* **Session Card**: Red-accented logout tile.
* **Manage Admins Card (Superadmin Only)**:
  - Opens the Admin Accounts Roster dialog.
  - **Add Admin Button**: Opens a searchable catalog of soldiers. Tapping "MAKE ADMIN" opens a credentials configuration window (Username & Password inputs) to promote that soldier.
  - **Accounts Directory**: Scrollable list of custom admins showing: `[Rank] [Name] ([Army Number])`.
  - **Edit Credentials Button**: Opens username/password modifiers.
  - **Delete Credentials Button**: Revokes admin status.
* **Manage Attributes Tile (Superadmin Only)**:
  - Opens the **Manage Attributes Screen** to configure regimental Trades, Ranks, and Batteries.
* **View All Groups Tile (Superadmin Only)**:
  - Opens the **View All Groups Screen** to see the list of active superadmin, admin, and user slot assignments.

---

### G. Battery Detail Screen
Provides detailed analytical and personnel breakdown of a selected battery unit.
* **Header & Stats Panel**: Renders a glassmorphism header card with battery specific color coding (e.g. Papa battery in gray, Romeo in green) showing total active strength, fighting ratio, and count breakdown by officers, JCOs, soldiers, and non-fighting personnel.
* **Smart Filter & Search**: Search bar to filter by name or army number. Filter chips to select specific personnel categories (All / Officers / JCOs / Soldiers / Non-Fighting).
* **Interactive Roster List**: Displays matching personnel details cards. Tapping any card launches the soldier's **Military ID Card Modal**.

---

### H. Manage Attributes Screen (Superadmin Only)
Allows customization and configuration of core database metadata constraints.
* **Tabbed Categorization**: Divided into three management segments: **Trades**, **Ranks**, and **Batteries**.
* **Attributes Registry**: Scrollable list of active tags.
* **Dynamic Modifiers (CRUD)**:
  - **Add Tag Button**: Add a new trade designation, military rank title, or battery code.
  - **Edit Badge Indicator**: Update names of existing items.
  - **Delete Indicator**: Remove attributes from future select lists.

---

### I. View All Groups Screen (Superadmin Only)
Renders a comprehensive directory of system credentials and access slots.
* **Categorized Directory**: Groups credentials by authorization levels: **Superadmin**, **Admins**, and **Users**.
* **Account Info Card**: Displays username, slot designation, and associated account profile metrics.

---

## 4. Input Fields & Form Specifications

### A. Roster Soldier Form (Nominal Roll CRUD)
* **Division Selectors**: Segmented Button Choice (`Fighting` vs. `Non-Fighting`).
* **Army Number Textbox**: Uppercase restricted string input (e.g., `PA-43337`, `3122918`). *Must be unique*.
* **Full Name Textbox**: Standard text field.
* **Trade Dropdown**: `['Gnr', 'TA', 'OCU', 'DMT', 'DSV', 'Svy', 'Civ', 'NCB', 'SW', 'Clk', 'Ck', 'Engr', 'LAD', 'N/A']`
* **Rank Dropdown**: `['Lt Col', 'Maj', 'Capt', 'Lt', '2/Lt', 'SM', 'Sub', 'N/Sub', 'BQMH', 'RQMH', 'RHM Hav', 'BHM Hav', 'Hav', 'Lhav', 'Nk', 'Lnk', 'Gnr', 'Clk', 'TA', 'OCU', 'DMT', 'DSV', 'Svy', 'Civ', 'NCB', 'SW', 'Ck', 'Engr']`
* **Class Dropdown**: `['Pb', 'Ptn', 'Sdh', 'Blh', 'AJK', 'GB']`
* **Phone Number Textbox**: Numeric input validator.
* **City Textbox**: Standard text field.
* **Remarks Textbox**: Multiline optional notes field.

### B. Category Roster Form (Dashboard Tree CRUD)
* **Parent Category Textbox**: Required text field.
* **Subcategory Textbox**: Optional text field.
* **Sub-Subcategory Textbox**: Optional text field.

---

## 5. Storage & Persistence Engine

The system uses `shared_preferences` for local data persistence.

```
┌────────────────────────┐      Serializes      ┌─────────────────────────┐
│     In-Memory State    ├─────────────────────►│  SharedPreferences Key  │
└────────────────────────┘                      └─────────────────────────┘
│ categoryHierarchy      │ ──[JSON String]────► │ "categoryHierarchy"     │
│ nominalRollList        │ ──[JSON List]──────► │ "nominalRollList"       │
│ statuses (Map)         │ ──[JSON Map]───────► │ "personnelStatuses"     │
│ customAdminAccounts    │ ──[JSON Map]───────► │ "customAdminAccounts"   │
│ isDarkMode (bool)      │ ───────────────────► │ "isDarkMode"            │
└────────────────────────┘                      └─────────────────────────┘
```

---

## 6. Implementation Notes for Web Developers

When converting this console to a web page:
1. **Responsive Viewports**:
   - The navigation tabs can be converted into a static **sidebar navigation menu** on wide screens (desktop views), folding into a responsive hamburger menu on tablet/mobile screens.
2. **Interactive ID Modals**:
   - Translate Flutter's `showDialog` modal cards into absolute-positioned hover overlays or center-aligned dialog box components.
3. **Optimized Renders**:
   - Use CSS gradients for headers (`background: linear-gradient(...)`) matching the gold gradient codes (`#FFF2C2` -> `#E9C54F` -> `#FFFFFF`).
4. **Offline Support**:
   - LocalStorage or IndexedDB can be utilized to mirror the `shared_preferences` key-value pairs for seamless offline operations.
