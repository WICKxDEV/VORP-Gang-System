# VORP Gang Management System

Professional, production-ready Gang Management system for RedM VORPCORE servers. Built with a focus on performance, security, and immersive cinematic design.

## 🌟 Features

- **In-Game Creation**: Players can create their own gangs for a configurable cost.
- **Dynamic Hierarchy**: 5-tier rank system (Leader, Co-Leader, Enforcer, Member, Prospect).
- **Permissions System**: Rank-based permissions for inviting, kicking, and managing funds/ranks.
- **Cinematic NUI**: Modern Western-style interface with frosted glass effects and responsive design.
- **Optimized Performance**: 0.01ms idle time, using efficient sync and server-side authority.
- **Multiplayer Synchronized**: Real-time roster and data updates across all players.
- **Secure**: Distance-checked invitations and server-side validation for all sensitive actions.

## 📋 Dependencies

- [VORPCORE](https://github.com/VORP-Core/vorp_core-lua)
- [oxmysql](https://github.com/overextended/oxmysql)

## 🚀 Installation

1. **Download**: Export the `vorp_gangs` folder.
2. **Move Resources**: Place the `vorp_gangs` folder into your RedM server's `resources` directory.
3. **Database Setup**:
   - Run the SQL file located in `vorp_gangs/sql/gangs.sql` in your database manager (HeidiSQL, phpMyAdmin, etc.).
4. **Configuration**:
   - Open `vorp_gangs/config.lua`.
   - Adjust the `CreateCost`, `Ranks`, and `Locales` to fit your server's economy and language.
5. **Add to server.cfg**:
   - Add `ensure vorp_gangs` to your `server.cfg` file.
6. **Restart**: Restart your server or start the resource via console.

## ⚙️ Configuration

The `config.lua` allows you to customize:
- `Config.CreateCost`: How much $ it costs to register a new gang.
- `Config.Ranks`: Define rank names and assign specific permission sets.
- `Config.OpenMenuKey`: The key used to toggle the gang interface.
- `Config.InviteDistance`: Max distance allowed to invite nearby players.

## 🎮 How to Use

- **Open Menu**: Press `O` (default) or use `/gang` command to open the Gang Management Menu.
- **Create Gang**: Use `/creategang [name]` or press the open menu key to start the creation process (requires $150).
- **Check Status**: Use `/mygang` to see your current gang and rank.
- **Leave**: Use `/leavegang` to quit your current gang (Members/Enforcers only).
- **Invite/Kick (ID)**: Use `/ganginvite [id]` or `/gangkick [id]` for quick member management.
- **Invite (Near)**: Stand near a player and use the "Invite Nearby" button in the menu.

## 🛠️ Technical Details

- **Language**: Lua 5.4 / JavaScript (NUI)
- **Framework**: VORPCORE
- **Frontend**: Vue 3.0
- **Storage**: MySQL via oxmysql

## 🔒 Security

- All server events are validated for player distance and permissions.
- Money removal is handled strictly on the server-side.
- Database operations use prepared statements to prevent SQL injection.

## 🤝 Credits

Developed by [WICKxDEV](https://github.com/WICKxDEV). For support or contributions, please refer to the official VORP documentation.
