import { motion } from "motion/react";
import { 
  Users, 
  Shield, 
  Database, 
  Terminal, 
  Copy, 
  ExternalLink,
  Info,
  Clock,
  Code
} from "lucide-react";

export default function App() {
  const installationSteps = [
    { title: "Download", desc: "Export this project as a ZIP or to GitHub." },
    { title: "Extract", desc: "Place the 'vorp_gangs' folder into your RedM server resources directory." },
    { title: "Database", desc: "Run the SQL schema located in 'vorp_gangs/sql/gangs.sql' in your database manager." },
    { title: "Configure", desc: "Edit 'vorp_gangs/config.lua' to customize ranks, prices, and settings." },
    { title: "Start", desc: "Add 'ensure vorp_gangs' to your server.cfg file." }
  ];

  return (
    <div className="min-h-screen bg-[#0c0c0c] text-[#e0d8cc] font-serif selection:bg-amber-900 selection:text-white relative overflow-hidden">
      {/* Background Ambient Glows */}
      <div className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] bg-amber-900/10 blur-[150px] rounded-full pointer-events-none" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-red-900/10 blur-[120px] rounded-full pointer-events-none" />
      <div className="absolute top-[30%] right-[-5%] w-[30%] h-[30%] bg-amber-500/5 blur-[100px] rounded-full pointer-events-none" />

      {/* Header Section */}
      <header className="relative z-10 py-16 px-6 border-b border-white/10 bg-black/40 backdrop-blur-md">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-end gap-8">
          <motion.div 
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <h2 className="text-xs uppercase tracking-[0.4em] text-amber-500 font-sans mb-2 font-bold">Outlaw Syndicate Management</h2>
            <h1 className="text-6xl md:text-8xl font-black tracking-tighter uppercase leading-none italic">
              VORP <span className="text-white">GANGS</span>
            </h1>
          </motion.div>
          
          <motion.div 
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="text-right font-sans hidden md:block"
          >
            <div className="text-4xl font-light tabular-nums text-white">$150.00</div>
            <div className="text-[10px] uppercase tracking-widest text-white/40">Initial Creation Cost</div>
          </motion.div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-20 relative z-10 space-y-32">
        
        {/* Core Description */}
        <section className="max-w-3xl">
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-2xl md:text-3xl text-white/60 leading-relaxed italic"
          >
            A high-performance, secure, and cinematic gang management system 
            built specifically for the VORPcore framework. Designed for the 
            toughest outlaws in the West.
          </motion.p>
        </section>

        {/* Features Grid */}
        <section>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              { icon: Users, title: "Multiplayer Sync", desc: "Real-time synchronization of gang rosters, ranks, and treasury using optimized server-side logic." },
              { icon: Shield, title: "Advanced Security", desc: "Distance checks and server-side authority mapping to prevent exploits and unauthorized actions." },
              { icon: Terminal, title: "NUI Dashboard", desc: "A modern, RDR2-inspired cinematic interface for managing members and permissions." }
            ].map((feature, i) => (
              <motion.div 
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="p-8 bg-white/5 backdrop-blur-xl border border-white/10 rounded-xl hover:bg-white/10 transition-all group"
              >
                <feature.icon className="w-10 h-10 text-amber-500 mb-6 group-hover:scale-110 transition-transform" />
                <h3 className="text-xl font-bold mb-3 italic tracking-tight">0{i+1}. {feature.title}</h3>
                <p className="text-white/40 leading-relaxed font-sans text-sm">{feature.desc}</p>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Installation Guide */}
        <section className="grid grid-cols-1 lg:grid-cols-12 gap-12">
          <div className="lg:col-span-12 mb-8">
            <h2 className="text-4xl font-bold italic tracking-tighter uppercase mb-2">The Deployment Path</h2>
            <div className="w-20 h-1 bg-amber-500" />
          </div>

          <div className="lg:col-span-5 space-y-4">
            {installationSteps.map((step, i) => (
              <motion.div 
                key={i}
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.05 }}
                className="bg-white/5 backdrop-blur-md border border-white/10 rounded-lg p-5 flex gap-4 group hover:bg-white/10 transition-colors"
              >
                <div className="w-8 h-8 rounded bg-amber-600/20 border border-amber-500/30 flex items-center justify-center text-xs font-bold text-amber-500">
                  {i + 1}
                </div>
                <div>
                  <h4 className="font-bold text-white uppercase tracking-wider text-sm mb-1">{step.title}</h4>
                  <p className="text-white/40 text-xs font-sans leading-normal">{step.desc}</p>
                </div>
              </motion.div>
            ))}
          </div>

          <div className="lg:col-span-7 bg-white/5 backdrop-blur-2xl border border-white/10 rounded-2xl p-8 relative overflow-hidden h-full">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <Database className="w-4 h-4 text-amber-500" />
                <span className="text-[10px] uppercase tracking-[0.3em] font-sans text-white/40">Resource Definition / SQL</span>
              </div>
              <div className="flex gap-2">
                <div className="w-2 h-2 rounded-full bg-red-500/50" />
                <div className="w-2 h-2 rounded-full bg-amber-500/50" />
                <div className="w-2 h-2 rounded-full bg-green-500/50" />
              </div>
            </div>
            <pre className="text-xs text-white/60 font-mono overflow-x-auto leading-relaxed bg-black/40 p-6 rounded-lg border border-white/5">
              {`CREATE TABLE IF NOT EXISTS \`vorp_gangs\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`name\` varchar(50) NOT NULL,
  \`owner\` varchar(50) NOT NULL,
  \`balance\` decimal(15,2) DEFAULT 0.00,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS \`vorp_gang_members\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`gang_id\` int(11) NOT NULL,
  \`char_identifier\` varchar(50) NOT NULL,
  \`rank\` int(11) DEFAULT 1,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB;`}
            </pre>
          </div>
        </section>

        {/* Interface Preview Mockup */}
        <section>
          <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-1 overflow-hidden">
            <div className="bg-[#0c0c0c] rounded-[22px] overflow-hidden relative aspect-video border border-white/10">
              <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-transparent via-amber-500/50 to-transparent" />
              
              {/* Mock NUI Glass UI */}
              <div className="absolute inset-0 flex items-center justify-center p-12">
                <div className="w-full h-full bg-white/5 backdrop-blur-3xl border border-white/10 rounded-xl p-8 flex flex-col">
                  <header className="flex justify-between items-end mb-8 border-b border-white/10 pb-6">
                    <div>
                      <h2 className="text-[10px] uppercase tracking-[0.4em] text-amber-500 font-sans mb-1">Outlaw Syndicate</h2>
                      <h1 className="text-4xl font-black tracking-tighter uppercase leading-none italic text-white">The Blackwater <span className="opacity-40">Gentry</span></h1>
                    </div>
                    <div className="text-right font-sans">
                      <div className="text-2xl font-light tabular-nums text-white">$14,250.85</div>
                      <div className="text-[8px] uppercase tracking-widest text-white/40">Treasury Balance</div>
                    </div>
                  </header>

                  <div className="flex-1 grid grid-cols-3 gap-6 overflow-hidden">
                    <div className="col-span-1 space-y-2">
                       {[1, 2, 3, 4].map(i => (
                         <div key={i} className={`p-4 border rounded ${i === 1 ? 'bg-amber-600/20 border-amber-500/30' : 'bg-white/5 border-white/10 opacity-40'}`}>
                            <div className="text-[10px] uppercase tracking-wider font-bold">Option {i}</div>
                         </div>
                       ))}
                    </div>
                    <div className="col-span-2 bg-white/5 rounded-xl border border-white/10 p-6">
                       <div className="h-full border border-dashed border-white/10 flex items-center justify-center text-white/10 uppercase text-xs tracking-widest italic">
                          Main Roster Control View
                       </div>
                    </div>
                  </div>
                </div>
              </div>

              <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-6 text-[8px] uppercase tracking-widest text-white/40 font-sans">
                 <span className="flex items-center gap-1.5"><span className="w-1 h-1 bg-green-500 rounded-full" /> VORPCORE Sync</span>
                 <span className="flex items-center gap-1.5"><span className="w-1 h-1 bg-amber-500 rounded-full" /> Live Preview</span>
              </div>
            </div>
          </div>
        </section>

        {/* Tech Specs */}
        <section className="grid grid-cols-1 md:grid-cols-2 gap-12 py-20 border-t border-white/10">
          <div>
            <h3 className="text-2xl font-bold italic mb-6 uppercase tracking-tighter">Technical Manifest</h3>
            <div className="space-y-4">
              <div className="flex justify-between items-center py-3 border-b border-white/5">
                <span className="text-white/40 uppercase text-xs tracking-widest font-sans">Resmon Idle</span>
                <span className="font-mono text-green-400 text-sm">0.01ms</span>
              </div>
              <div className="flex justify-between items-center py-3 border-b border-white/5">
                <span className="text-white/40 uppercase text-xs tracking-widest font-sans">Framework</span>
                <span className="font-sans text-amber-500 text-xs font-bold">VORPCORE / RDR3</span>
              </div>
              <div className="flex justify-between items-center py-3 border-b border-white/5">
                <span className="text-white/40 uppercase text-xs tracking-widest font-sans">Persistence</span>
                <span className="font-sans text-white text-xs">OXMYSQL Async</span>
              </div>
            </div>
          </div>
          <div className="bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl p-8 flex flex-col justify-center text-center">
            <h4 className="text-lg font-bold italic text-amber-500 mb-2 uppercase tracking-tight">Need Support?</h4>
            <p className="text-white/40 font-sans text-sm mb-6 max-w-xs mx-auto">Access the full documentation and community Discord for integration guides.</p>
            <div className="flex gap-4 justify-center">
              <button className="px-6 py-3 bg-white text-black font-bold uppercase text-[10px] tracking-widest hover:bg-neutral-200 transition-colors">Documentation</button>
              <button className="px-6 py-3 border border-white/10 text-white font-bold uppercase text-[10px] tracking-widest hover:bg-white/5 transition-colors">Discord</button>
            </div>
          </div>
        </section>

      </main>

      <footer className="relative z-10 py-12 px-6 border-t border-white/5 text-center space-y-4">
        <p className="text-[10px] uppercase tracking-[0.5em] text-white/20 font-sans">
          RedM Systems • Syndicate Dynamics • 1899
        </p>
        <p className="text-[10px] uppercase tracking-widest text-white/10 font-sans">
          Developed by <a href="https://github.com/WICKxDEV" target="_blank" rel="noreferrer" className="text-amber-500/50 hover:text-amber-500 transition-colors">WICKxDEV</a>
        </p>
      </footer>
    </div>
  );
}


