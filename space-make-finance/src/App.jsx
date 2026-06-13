import { useEffect, useMemo, useState } from "react";
import {
  ArrowDownLeft,
  ArrowUpRight,
  BarChart3,
  Building2,
  CalendarDays,
  CheckCircle2,
  ChevronDown,
  ClipboardList,
  Download,
  FileText,
  Filter,
  Home,
  IndianRupee,
  Menu,
  Paperclip,
  Plus,
  ReceiptText,
  Search,
  Settings,
  SlidersHorizontal,
  Upload,
  Users,
  WalletCards,
  X,
} from "lucide-react";

const STORAGE_KEY = "space-make-finance-v1";

const people = ["Kumaresh", "Aravinth", "Jayabalaji"];
const sources = [
  "HDFC Bank",
  "ICICI Bank",
  "Company Cash",
  "Kumaresh Float",
  "Aravinth Float",
  "Jayabalaji Float",
];
const transactionTypes = [
  "Client Payment",
  "Vendor Payment",
  "Labour Payment",
  "Material Purchase",
  "Transport",
  "Office Expense",
  "Miscellaneous Expense",
];
const billTypes = [
  "Vendor Bill",
  "Labour Bill",
  "Payment Receipt",
  "Client Payment Proof",
  "Agreement",
  "Site Photo",
  "Other",
];
const variationTypes = [
  "Material Escalation",
  "Extra Work",
  "Client Upgrade",
  "Scope Change",
  "Deduction",
];

const seedData = {
  projects: [
    { id: "p1", name: "Lake View Residency", client: "Mr. Prakash", code: "LVR-001", site: "Coimbatore", contractValue: 12000000, status: "In Progress" },
    { id: "p2", name: "Greenfield Villas", client: "Mr. Raman", code: "GFV-014", site: "Erode", contractValue: 9500000, status: "In Progress" },
    { id: "p3", name: "Skyline Apartments", client: "ABC Developers", code: "SKY-032", site: "Chennai", contractValue: 25000000, status: "In Progress" },
    { id: "p4", name: "Sri Sai Enclave", client: "Mr. Selvam", code: "SSE-009", site: "Salem", contractValue: 8000000, status: "Pending" },
    { id: "p5", name: "Whitefield Office", client: "TechSoft Ltd", code: "WFO-021", site: "Bengaluru", contractValue: 15000000, status: "In Progress" },
    { id: "p6", name: "Temple Road House", client: "Mrs. Revathi", code: "TRH-005", site: "Madurai", contractValue: 4500000, status: "Upcoming" },
  ],
  transactions: [
    tx("t1", "2026-06-12", "Client Payment", 1200000, "Kumaresh", "HDFC Bank", "Client", "Stage 4 collection", [{ projectId: "p1", amount: 1200000 }], "Payment Receipt", "RCPT-1548"),
    tx("t2", "2026-06-11", "Material Purchase", 245000, "Jayabalaji", "ICICI Bank", "Sri Murugan Traders", "Steel and cement purchase", [{ projectId: "p1", amount: 245000 }], "Vendor Bill", "BILL-2547"),
    tx("t3", "2026-06-10", "Labour Payment", 85000, "Aravinth", "Company Cash", "Labour Group", "Masonry labour", [{ projectId: "p1", amount: 85000 }], "Labour Bill", ""),
    tx("t4", "2026-06-09", "Client Payment", 500000, "Kumaresh", "HDFC Bank", "Client", "Advance received", [{ projectId: "p2", amount: 500000 }], "Client Payment Proof", "RCPT-1512"),
    tx("t5", "2026-06-08", "Material Purchase", 115000, "Jayabalaji", "Kumaresh Float", "Bricks and Sand", "Block work material", [{ projectId: "p1", amount: 70000 }, { projectId: "p2", amount: 45000 }], "Vendor Bill", "BILL-2511"),
    tx("t6", "2026-06-06", "Client Payment", 6800000, "Kumaresh", "HDFC Bank", "Client", "Milestone receipts", [{ projectId: "p1", amount: 4800000 }, { projectId: "p3", amount: 2000000 }], "Payment Receipt", "RCPT-1484"),
    tx("t7", "2026-06-05", "Transport", 36000, "Aravinth", "Company Cash", "Vel Transport", "Site material transport", [{ projectId: "p3", amount: 36000 }], "Other", ""),
  ],
  variations: [
    variation("v1", "p1", "Extra Work", "Premium kitchen tile upgrade", 840000, "Approved", "VAR-101"),
    variation("v2", "p1", "Scope Change", "Compound wall extension", 260000, "Pending", "VAR-107"),
    variation("v3", "p2", "Material Escalation", "Steel price revision", 425000, "Approved", "VAR-089"),
    variation("v4", "p3", "Client Upgrade", "Lobby granite upgrade", 950000, "Collected", "VAR-073"),
  ],
  documents: [
    doc("d1", "p1", "Agreement", "Lake View Agreement.pdf", "Kumaresh", "2026-06-01"),
    doc("d2", "p2", "Site Photo", "Greenfield footing photo.jpg", "Aravinth", "2026-06-04"),
  ],
};

function tx(id, date, type, amount, paidBy, source, vendor, notes, allocations, billType, refNo) {
  return {
    id,
    date,
    type,
    amount,
    paidBy,
    source,
    vendor,
    notes,
    allocations,
    attachment: refNo
      ? {
          id: `${id}-a`,
          name: `${refNo}.pdf`,
          type: billType,
          refNo,
          uploadedBy: paidBy,
          uploadedAt: date,
          dataUrl: "",
        }
      : null,
  };
}

function variation(id, projectId, type, description, amount, status, refNo) {
  return { id, projectId, type, description, amount, status, refNo, attachment: null };
}

function doc(id, projectId, type, name, uploadedBy, uploadedAt) {
  return { id, projectId, type, name, uploadedBy, uploadedAt, dataUrl: "" };
}

const money = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0,
});

function formatMoney(value) {
  return money.format(Math.round(value || 0));
}

function formatCompactMoney(value) {
  const amount = Math.round(value || 0);
  if (Math.abs(amount) >= 10000000) return `${money.format(amount / 10000000).replace(".00", "")} Cr`;
  if (Math.abs(amount) >= 100000) return `${money.format(amount / 100000).replace(".00", "")} L`;
  return formatMoney(amount);
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function useFinanceState() {
  const [data, setData] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (!saved) return seedData;
    try {
      return JSON.parse(saved);
    } catch {
      return seedData;
    }
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  }, [data]);

  return [data, setData];
}

function useProjectStats(data) {
  return useMemo(() => {
    const byProject = new Map();
    data.projects.forEach((project) => {
      byProject.set(project.id, {
        project,
        collected: 0,
        spent: 0,
        approvedVariations: 0,
        pendingVariations: 0,
        revisedContract: project.contractValue,
        balanceToCollect: project.contractValue,
      });
    });

    data.transactions.forEach((transaction) => {
      transaction.allocations.forEach((allocation) => {
        const item = byProject.get(allocation.projectId);
        if (!item) return;
        if (transaction.type === "Client Payment") item.collected += Number(allocation.amount);
        else item.spent += Number(allocation.amount);
      });
    });

    data.variations.forEach((item) => {
      const stats = byProject.get(item.projectId);
      if (!stats) return;
      if (item.status === "Approved" || item.status === "Collected") {
        stats.approvedVariations += Number(item.amount);
      } else {
        stats.pendingVariations += Number(item.amount);
      }
    });

    byProject.forEach((item) => {
      item.revisedContract = item.project.contractValue + item.approvedVariations;
      item.balanceToCollect = item.revisedContract - item.collected;
    });

    return byProject;
  }, [data]);
}

function App() {
  const [data, setData] = useFinanceState();
  const stats = useProjectStats(data);
  const [activeNav, setActiveNav] = useState("Projects");
  const [selectedProjectId, setSelectedProjectId] = useState(data.projects[0]?.id || "");
  const [transactionOpen, setTransactionOpen] = useState(false);
  const [billOpen, setBillOpen] = useState(false);
  const [variationOpen, setVariationOpen] = useState(false);
  const [projectOpen, setProjectOpen] = useState(false);
  const [quickMode, setQuickMode] = useState("Money Out");
  const [toast, setToast] = useState("");

  useEffect(() => {
    if (toast) {
      const timer = setTimeout(() => setToast(""), 2600);
      return () => clearTimeout(timer);
    }
  }, [toast]);

  const selectedProject = data.projects.find((project) => project.id === selectedProjectId) || data.projects[0];
  const selectedStats = selectedProject ? stats.get(selectedProject.id) : null;

  const totals = useMemo(() => {
    let collections = 0;
    let spending = 0;
    let approvedVariations = 0;
    let pendingCollection = 0;
    stats.forEach((item) => {
      collections += item.collected;
      spending += item.spent;
      approvedVariations += item.approvedVariations;
      pendingCollection += item.balanceToCollect;
    });
    return {
      collections,
      spending,
      cashBalance: collections - spending,
      pendingCollection,
      approvedVariations,
    };
  }, [stats]);

  function addTransaction(transaction) {
    setData((current) => ({
      ...current,
      transactions: [{ ...transaction, id: crypto.randomUUID() }, ...current.transactions],
      documents: transaction.attachment
        ? [{ ...transaction.attachment, id: crypto.randomUUID(), projectId: transaction.allocations[0]?.projectId || selectedProjectId }, ...current.documents]
        : current.documents,
    }));
    setToast("Transaction saved");
  }

  function addBill(document) {
    setData((current) => ({
      ...current,
      documents: [{ ...document, id: crypto.randomUUID() }, ...current.documents],
    }));
    setToast("Bill uploaded");
  }

  function addVariation(item) {
    setData((current) => ({
      ...current,
      variations: [{ ...item, id: crypto.randomUUID() }, ...current.variations],
    }));
    setToast("Variation saved");
  }

  function addProject(project) {
    const newProject = { ...project, id: crypto.randomUUID(), code: project.code || `SPM-${currentCode(data.projects.length + 1)}` };
    setData((current) => ({ ...current, projects: [newProject, ...current.projects] }));
    setSelectedProjectId(newProject.id);
    setActiveNav("Projects");
    setToast("Project added");
  }

  return (
    <div className="app-shell">
      <Sidebar activeNav={activeNav} setActiveNav={setActiveNav} />
      <main className="workspace">
        <TopBar
          activeNav={activeNav}
          onAddTransaction={() => setTransactionOpen(true)}
          onAddBill={() => setBillOpen(true)}
          onAddVariation={() => setVariationOpen(true)}
          onAddProject={() => setProjectOpen(true)}
        />

        {activeNav === "Dashboard" && <Dashboard totals={totals} data={data} stats={stats} setActiveNav={setActiveNav} />}
        {activeNav === "Projects" && (
          <ProjectWorkspace
            data={data}
            stats={stats}
            selectedProjectId={selectedProject?.id}
            setSelectedProjectId={setSelectedProjectId}
            selectedStats={selectedStats}
          />
        )}
        {activeNav === "Transactions" && <TransactionsView data={data} stats={stats} />}
        {activeNav === "Bills" && <BillsView data={data} onUpload={() => setBillOpen(true)} />}
        {activeNav === "Variations" && <VariationsView data={data} onAdd={() => setVariationOpen(true)} />}
        {activeNav === "People" && <PeopleView data={data} />}
        {activeNav === "Reports" && <ReportsView totals={totals} data={data} stats={stats} />}
        {activeNav === "Settings" && <SettingsView onReset={() => { localStorage.removeItem(STORAGE_KEY); setData(seedData); setToast("Sample data restored"); }} />}
      </main>

      <SupervisorPocket
        data={data}
        selectedProject={selectedProject}
        selectedStats={selectedStats}
        quickMode={quickMode}
        setQuickMode={setQuickMode}
        onSave={addTransaction}
      />

      <MobileNav activeNav={activeNav} setActiveNav={setActiveNav} openQuick={() => setTransactionOpen(true)} />

      {transactionOpen && (
        <TransactionModal
          data={data}
          initialProjectId={selectedProject?.id}
          initialType={quickMode === "Money In" ? "Client Payment" : "Material Purchase"}
          onClose={() => setTransactionOpen(false)}
          onSave={(transaction) => {
            addTransaction(transaction);
            setTransactionOpen(false);
          }}
        />
      )}
      {billOpen && (
        <BillModal
          projects={data.projects}
          onClose={() => setBillOpen(false)}
          onSave={(document) => {
            addBill(document);
            setBillOpen(false);
          }}
        />
      )}
      {variationOpen && (
        <VariationModal
          projects={data.projects}
          initialProjectId={selectedProject?.id}
          onClose={() => setVariationOpen(false)}
          onSave={(item) => {
            addVariation(item);
            setVariationOpen(false);
          }}
        />
      )}
      {projectOpen && (
        <ProjectModal
          onClose={() => setProjectOpen(false)}
          onSave={(project) => {
            addProject(project);
            setProjectOpen(false);
          }}
        />
      )}
      {toast && <div className="toast"><CheckCircle2 size={17} />{toast}</div>}
    </div>
  );
}

function currentCode(value) {
  return String(value).padStart(3, "0");
}

function Sidebar({ activeNav, setActiveNav }) {
  const items = [
    ["Dashboard", Home],
    ["Projects", Building2],
    ["Transactions", SlidersHorizontal],
    ["Bills", FileText],
    ["Variations", ReceiptText],
    ["People", Users],
    ["Reports", BarChart3],
    ["Settings", Settings],
  ];
  return (
    <aside className="sidebar">
      <div className="brand">
        <div className="brand-mark"><Building2 size={19} /></div>
        <div>
          <strong>SPACE MAKE</strong>
          <span>FINANCE V1</span>
        </div>
      </div>
      <nav className="side-nav">
        {items.map(([label, Icon]) => (
          <button key={label} className={activeNav === label ? "active" : ""} onClick={() => setActiveNav(label)}>
            <Icon size={18} />
            <span>{label}</span>
          </button>
        ))}
      </nav>
      <div className="user-box">
        <span className="avatar">KS</span>
        <span><strong>Kumaresh</strong><small>Owner</small></span>
        <ChevronDown size={17} />
      </div>
    </aside>
  );
}

function TopBar({ activeNav, onAddTransaction, onAddBill, onAddVariation, onAddProject }) {
  return (
    <header className="topbar">
      <div>
        <h1>{activeNav}</h1>
        <p>{activeNav === "Projects" ? "All projects and their financial overview" : "Space Make construction finance workspace"}</p>
      </div>
      <div className="top-actions">
        <ActionButton icon={Plus} label="Add Transaction" onClick={onAddTransaction} tone="teal" />
        <ActionButton icon={Plus} label="Add Bill" onClick={onAddBill} tone="red" />
        <ActionButton icon={Plus} label="Add Variation" onClick={onAddVariation} tone="amber" />
        <ActionButton icon={Plus} label="Add Project" onClick={onAddProject} tone="dark" />
      </div>
    </header>
  );
}

function ActionButton({ icon: Icon, label, onClick, tone = "teal" }) {
  return (
    <button className={`action ${tone}`} onClick={onClick} title={label}>
      <Icon size={17} />
      <span>{label}</span>
    </button>
  );
}

function Dashboard({ totals, data, stats, setActiveNav }) {
  const topProjects = [...stats.values()].sort((a, b) => b.balanceToCollect - a.balanceToCollect).slice(0, 5);
  return (
    <section className="page-grid dashboard-grid">
      <SummaryStrip totals={totals} />
      <Panel title="Top Projects">
        <div className="ranked-list">
          {topProjects.map((item, index) => (
            <button className="rank-row" key={item.project.id} onClick={() => setActiveNav("Projects")}>
              <span className="rank">{index + 1}</span>
              <span><strong>{item.project.name}</strong><small>{item.project.client}</small></span>
              <span>{formatMoney(item.balanceToCollect)}</span>
            </button>
          ))}
        </div>
      </Panel>
      <Panel title="Recent Activity">
        <MiniActivity transactions={data.transactions.slice(0, 6)} projects={data.projects} />
      </Panel>
    </section>
  );
}

function SummaryStrip({ totals }) {
  const cards = [
    ["Total Collections", totals.collections, "up", IndianRupee],
    ["Total Spending", totals.spending, "down", WalletCards],
    ["Cash Balance", totals.cashBalance, "up", WalletCards],
    ["Pending Collection", totals.pendingCollection, "warn", ReceiptText],
    ["Approved Variations", totals.approvedVariations, "up", ClipboardList],
  ];
  return (
    <div className="summary-strip">
      {cards.map(([label, value, trend, Icon]) => (
        <div className="metric" key={label}>
          <span className={`metric-icon ${trend}`}><Icon size={20} /></span>
          <span>
            <small>{label}</small>
            <strong title={formatMoney(value)}>{formatCompactMoney(value)}</strong>
            <em>{trend === "down" ? "Expenses tracked" : trend === "warn" ? "To collect" : "Updated live"}</em>
          </span>
        </div>
      ))}
    </div>
  );
}

function ProjectWorkspace({ data, stats, selectedProjectId, setSelectedProjectId, selectedStats }) {
  const [query, setQuery] = useState("");
  const filtered = data.projects.filter((project) => `${project.name} ${project.client}`.toLowerCase().includes(query.toLowerCase()));
  return (
    <section className="project-workspace">
      <SummaryStrip totals={calculateTotals(stats)} />
      <div className="ledger-grid">
        <Panel
          title={`All Projects (${filtered.length})`}
          actions={<SearchBox value={query} onChange={setQuery} placeholder="Search project or client" />}
        >
          <ProjectTable projects={filtered} stats={stats} selectedId={selectedProjectId} onSelect={setSelectedProjectId} />
        </Panel>
        {selectedStats && <ProjectDetail data={data} stats={selectedStats} />}
      </div>
      <TransactionsView data={data} stats={stats} compact />
    </section>
  );
}

function calculateTotals(stats) {
  const result = { collections: 0, spending: 0, cashBalance: 0, pendingCollection: 0, approvedVariations: 0 };
  stats.forEach((item) => {
    result.collections += item.collected;
    result.spending += item.spent;
    result.pendingCollection += item.balanceToCollect;
    result.approvedVariations += item.approvedVariations;
  });
  result.cashBalance = result.collections - result.spending;
  return result;
}

function Panel({ title, actions, children }) {
  return (
    <section className="panel">
      <div className="panel-head">
        <h2>{title}</h2>
        {actions}
      </div>
      {children}
    </section>
  );
}

function SearchBox({ value, onChange, placeholder }) {
  return (
    <label className="search-box">
      <Search size={17} />
      <input value={value} onChange={(event) => onChange(event.target.value)} placeholder={placeholder} />
    </label>
  );
}

function ProjectTable({ projects, stats, selectedId, onSelect }) {
  return (
    <div className="table-wrap project-table">
      <table>
        <thead>
          <tr>
            <th>Project Name</th>
            <th>Client</th>
            <th>Contract Value</th>
            <th>Collected</th>
            <th>Spent</th>
            <th>Balance To Collect</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {projects.map((project) => {
            const item = stats.get(project.id);
            return (
              <tr key={project.id} className={selectedId === project.id ? "selected" : ""} onClick={() => onSelect(project.id)}>
                <td><strong>{project.name}</strong></td>
                <td>{project.client}</td>
                <td>{formatMoney(project.contractValue)}</td>
                <td>{formatMoney(item?.collected)}</td>
                <td>{formatMoney(item?.spent)}</td>
                <td>{formatMoney(item?.balanceToCollect)}</td>
                <td><StatusBadge status={project.status} /></td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

function ProjectDetail({ data, stats }) {
  const { project } = stats;
  const progress = Math.min(100, stats.revisedContract ? (stats.collected / stats.revisedContract) * 100 : 0);
  const projectTransactions = data.transactions.filter((transaction) => transaction.allocations.some((item) => item.projectId === project.id)).slice(0, 6);
  const variations = data.variations.filter((item) => item.projectId === project.id);
  const bills = data.documents.filter((item) => item.projectId === project.id);
  const [tab, setTab] = useState("Transactions");

  return (
    <section className="panel project-detail">
      <div className="detail-title">
        <div>
          <h2>{project.name}</h2>
          <p>Client: {project.client} <span>|</span> Project Code: {project.code} <span>|</span> Site: {project.site}</p>
        </div>
        <StatusBadge status={project.status} />
      </div>
      <div className="detail-metrics">
        <MiniMetric label="Contract Value" value={stats.project.contractValue} />
        <MiniMetric label="Approved Variations" value={stats.approvedVariations} positive />
        <MiniMetric label="Revised Contract Value" value={stats.revisedContract} />
        <MiniMetric label="Balance To Collect" value={stats.balanceToCollect} danger />
      </div>
      <div className="progress-block">
        <div><strong>Collection Progress</strong><span>{progress.toFixed(1)}%</span></div>
        <div className="progress"><span style={{ width: `${progress}%` }} /></div>
        <small>{formatMoney(stats.collected)} of {formatMoney(stats.revisedContract)}</small>
      </div>
      <div className="tabs">
        {["Transactions", "Variations", "Bills", "Summary"].map((item) => (
          <button key={item} className={tab === item ? "active" : ""} onClick={() => setTab(item)}>
            {item}
            {item === "Variations" && variations.length > 0 && <em>{variations.length}</em>}
            {item === "Bills" && bills.length > 0 && <em>{bills.length}</em>}
          </button>
        ))}
      </div>
      {tab === "Transactions" && <MiniActivity transactions={projectTransactions} projects={data.projects} />}
      {tab === "Variations" && <VariationRows variations={variations} projects={data.projects} />}
      {tab === "Bills" && <DocumentRows documents={bills} projects={data.projects} />}
      {tab === "Summary" && (
        <div className="summary-balance">
          <MiniMetric label="Total Collections" value={stats.collected} positive />
          <MiniMetric label="Total Spending" value={stats.spent} danger />
          <MiniMetric label="Current Balance" value={stats.collected - stats.spent} />
        </div>
      )}
    </section>
  );
}

function MiniMetric({ label, value, positive, danger }) {
  return (
    <div className="mini-metric">
      <small>{label}</small>
      <strong className={positive ? "positive" : danger ? "danger" : ""}>{formatMoney(value)}</strong>
    </div>
  );
}

function StatusBadge({ status }) {
  return <span className={`status ${status.toLowerCase().replaceAll(" ", "-")}`}>{status}</span>;
}

function TransactionsView({ data, compact = false }) {
  const [filters, setFilters] = useState({ project: "All Projects", type: "All Types", paidBy: "Paid By", source: "Source", vendor: "", date: "" });
  const filtered = data.transactions.filter((transaction) => {
    const projectNames = transaction.allocations.map((item) => data.projects.find((project) => project.id === item.projectId)?.name);
    return (
      (filters.project === "All Projects" || projectNames.includes(filters.project)) &&
      (filters.type === "All Types" || transaction.type === filters.type) &&
      (filters.paidBy === "Paid By" || transaction.paidBy === filters.paidBy) &&
      (filters.source === "Source" || transaction.source === filters.source) &&
      (!filters.vendor || transaction.vendor.toLowerCase().includes(filters.vendor.toLowerCase())) &&
      (!filters.date || transaction.date === filters.date)
    );
  });
  const debit = filtered.reduce((sum, item) => item.type === "Client Payment" ? sum : sum + item.amount, 0);
  const credit = filtered.reduce((sum, item) => item.type === "Client Payment" ? sum + item.amount : sum, 0);

  return (
    <Panel title="Transaction History">
      <div className="filters">
        <Input icon={CalendarDays} type="date" value={filters.date} onChange={(date) => setFilters({ ...filters, date })} />
        <Select value={filters.project} onChange={(project) => setFilters({ ...filters, project })} options={["All Projects", ...data.projects.map((project) => project.name)]} />
        <Select value={filters.type} onChange={(type) => setFilters({ ...filters, type })} options={["All Types", ...transactionTypes]} />
        <Select value={filters.paidBy} onChange={(paidBy) => setFilters({ ...filters, paidBy })} options={["Paid By", ...people]} />
        <Select value={filters.source} onChange={(source) => setFilters({ ...filters, source })} options={["Source", ...sources]} />
        <Input value={filters.vendor} onChange={(vendor) => setFilters({ ...filters, vendor })} placeholder="Vendor / Person" />
        <button className="filter-button"><Filter size={16} />Filter</button>
        <button className="reset-button" onClick={() => setFilters({ project: "All Projects", type: "All Types", paidBy: "Paid By", source: "Source", vendor: "", date: "" })}>Reset</button>
      </div>
      <div className={`table-wrap ${compact ? "compact-table" : ""}`}>
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Project</th>
              <th>Type</th>
              <th>Description</th>
              <th>Paid By</th>
              <th>Source</th>
              <th>Vendor / Person</th>
              <th>Bill / Ref No.</th>
              <th>Debit</th>
              <th>Credit</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((transaction) => (
              <tr key={transaction.id}>
                <td>{prettyDate(transaction.date)}</td>
                <td>{projectLabel(transaction.allocations, data.projects)}</td>
                <td><MoneyType type={transaction.type} /></td>
                <td>{transaction.notes}</td>
                <td>{transaction.paidBy}</td>
                <td>{transaction.source}</td>
                <td>{transaction.vendor}</td>
                <td>{transaction.attachment?.refNo || "-"}</td>
                <td>{transaction.type === "Client Payment" ? "-" : formatMoney(transaction.amount)}</td>
                <td>{transaction.type === "Client Payment" ? formatMoney(transaction.amount) : "-"}</td>
              </tr>
            ))}
          </tbody>
          <tfoot>
            <tr>
              <td colSpan="8">Total</td>
              <td>{formatMoney(debit)}</td>
              <td>{formatMoney(credit)}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </Panel>
  );
}

function MoneyType({ type }) {
  const incoming = type === "Client Payment";
  return (
    <span className={`money-type ${incoming ? "in" : "out"}`}>
      {incoming ? <ArrowUpRight size={14} /> : <ArrowDownLeft size={14} />}
      {incoming ? "Money In" : "Money Out"}
    </span>
  );
}

function prettyDate(date) {
  return new Intl.DateTimeFormat("en-GB", { day: "2-digit", month: "short", year: "numeric" }).format(new Date(`${date}T00:00:00`));
}

function projectLabel(allocations, projects) {
  if (allocations.length > 1) return `${allocations.length} projects`;
  return projects.find((project) => project.id === allocations[0]?.projectId)?.name || "-";
}

function MiniActivity({ transactions, projects }) {
  if (!transactions.length) return <Empty label="No transactions found" />;
  return (
    <div className="activity-list">
      {transactions.map((transaction) => (
        <div className="activity-row" key={transaction.id}>
          <span>{prettyDate(transaction.date)}</span>
          <MoneyType type={transaction.type} />
          <strong>{transaction.notes}</strong>
          <span>{projectLabel(transaction.allocations, projects)}</span>
          <span className={transaction.type === "Client Payment" ? "positive" : "danger"}>{formatMoney(transaction.amount)}</span>
        </div>
      ))}
    </div>
  );
}

function BillsView({ data, onUpload }) {
  const [query, setQuery] = useState("");
  const docs = data.documents.filter((item) => `${item.name} ${item.type}`.toLowerCase().includes(query.toLowerCase()));
  return (
    <section className="page-grid">
      <Panel title="Bills & Documents" actions={<div className="panel-actions"><SearchBox value={query} onChange={setQuery} placeholder="Search bills" /><button className="filter-button" onClick={onUpload}><Upload size={16} />Upload</button></div>}>
        <DocumentRows documents={docs} projects={data.projects} />
      </Panel>
    </section>
  );
}

function DocumentRows({ documents, projects }) {
  if (!documents.length) return <Empty label="No bills uploaded" />;
  return (
    <div className="document-list">
      {documents.map((docItem) => (
        <div className="document-row" key={docItem.id}>
          <FileText size={18} />
          <span><strong>{docItem.name}</strong><small>{docItem.type} | {projects.find((project) => project.id === docItem.projectId)?.name || "No project"}</small></span>
          <span>{docItem.uploadedBy}</span>
          <span>{prettyDate(docItem.uploadedAt)}</span>
          {docItem.dataUrl ? <a href={docItem.dataUrl} download={docItem.name} title="Download"><Download size={17} /></a> : <button title="Preview not available"><Paperclip size={17} /></button>}
        </div>
      ))}
    </div>
  );
}

function VariationsView({ data, onAdd }) {
  return (
    <section className="page-grid">
      <Panel title="Variations" actions={<button className="filter-button" onClick={onAdd}><Plus size={16} />Add Variation</button>}>
        <VariationRows variations={data.variations} projects={data.projects} />
      </Panel>
    </section>
  );
}

function VariationRows({ variations, projects }) {
  if (!variations.length) return <Empty label="No variations added" />;
  return (
    <div className="variation-list">
      {variations.map((item) => (
        <div className="variation-row" key={item.id}>
          <span><strong>{item.description}</strong><small>{item.type} | {projects.find((project) => project.id === item.projectId)?.name}</small></span>
          <strong>{formatMoney(item.amount)}</strong>
          <StatusBadge status={item.status} />
        </div>
      ))}
    </div>
  );
}

function PeopleView({ data }) {
  const rows = people.map((person) => {
    const transactions = data.transactions.filter((item) => item.paidBy === person);
    const paid = transactions.filter((item) => item.type !== "Client Payment").reduce((sum, item) => sum + item.amount, 0);
    const collections = transactions.filter((item) => item.type === "Client Payment").reduce((sum, item) => sum + item.amount, 0);
    const docs = data.documents.filter((item) => item.uploadedBy === person).length + transactions.filter((item) => item.attachment?.uploadedBy === person).length;
    return { person, paid, collections, expenses: transactions.filter((item) => item.type !== "Client Payment").length, floatBalance: collections - paid, docs };
  });
  return (
    <section className="people-grid">
      {rows.map((row) => (
        <section className="person-panel" key={row.person}>
          <div className="person-head"><span className="avatar">{row.person.slice(0, 2).toUpperCase()}</span><h2>{row.person}</h2></div>
          <MiniMetric label="Payments Made" value={row.paid} danger />
          <MiniMetric label="Collections Received" value={row.collections} positive />
          <MiniMetric label="Float Balance" value={row.floatBalance} />
          <div className="person-foot"><span>{row.expenses} expenses logged</span><span>{row.docs} bills uploaded</span></div>
        </section>
      ))}
    </section>
  );
}

function ReportsView({ totals, data, stats }) {
  return (
    <section className="page-grid">
      <SummaryStrip totals={totals} />
      <Panel title="Project Collection Summary">
        <div className="report-list">
          {[...stats.values()].map((item) => (
            <div className="report-row" key={item.project.id}>
              <span><strong>{item.project.name}</strong><small>{item.project.client}</small></span>
              <ProgressValue current={item.collected} total={item.revisedContract} />
              <strong>{formatMoney(item.balanceToCollect)}</strong>
            </div>
          ))}
        </div>
      </Panel>
      <Panel title="Current Bills">
        <DocumentRows documents={data.documents.slice(0, 5)} projects={data.projects} />
      </Panel>
    </section>
  );
}

function ProgressValue({ current, total }) {
  const percent = total ? Math.min(100, (current / total) * 100) : 0;
  return (
    <div className="progress-cell">
      <div className="progress"><span style={{ width: `${percent}%` }} /></div>
      <small>{percent.toFixed(1)}%</small>
    </div>
  );
}

function SettingsView({ onReset }) {
  return (
    <section className="page-grid">
      <Panel title="Settings">
        <div className="settings-row">
          <span><strong>Local company data</strong><small>Projects, transactions, bills, variations, and people are stored in this browser.</small></span>
          <button className="reset-button" onClick={onReset}>Restore sample data</button>
        </div>
      </Panel>
    </section>
  );
}

function SupervisorPocket({ data, selectedProject, selectedStats, quickMode, setQuickMode, onSave }) {
  const progress = selectedStats?.revisedContract ? (selectedStats.collected / selectedStats.revisedContract) * 100 : 0;
  return (
    <aside className="pocket">
      <div className="pocket-head">
        <h2>Supervisor Pocket</h2>
        <span><i />Live</span>
      </div>
      {selectedProject && selectedStats && (
        <section className="pocket-project">
          <div><strong>{selectedProject.name}</strong><StatusBadge status={selectedProject.status} /></div>
          <small>Balance To Collect</small>
          <b>{formatMoney(selectedStats.balanceToCollect)}</b>
          <ProgressValue current={selectedStats.collected} total={selectedStats.revisedContract} />
        </section>
      )}
      <div className="quick-grid">
        {["Money In", "Money Out", "Upload Bill", "Variation"].map((item) => (
          <button key={item} className={quickMode === item ? "active" : ""} onClick={() => setQuickMode(item)}>
            {item === "Money In" && <ArrowUpRight size={22} />}
            {item === "Money Out" && <ArrowDownLeft size={22} />}
            {item === "Upload Bill" && <Paperclip size={22} />}
            {item === "Variation" && <ReceiptText size={22} />}
            <span>{item}</span>
          </button>
        ))}
      </div>
      <QuickEntry
        data={data}
        selectedProjectId={selectedProject?.id}
        mode={quickMode}
        onSave={onSave}
      />
    </aside>
  );
}

function QuickEntry({ data, selectedProjectId, mode, onSave }) {
  return (
    <section className="quick-entry">
      <h3>Quick Entry - {mode === "Money In" ? "Money In" : "Money Out"}</h3>
      <TransactionForm
        data={data}
        initialProjectId={selectedProjectId}
        initialType={mode === "Money In" ? "Client Payment" : "Material Purchase"}
        compact
        onSave={onSave}
      />
    </section>
  );
}

function TransactionModal({ data, initialProjectId, initialType, onClose, onSave }) {
  return (
    <Modal title="Add Transaction" onClose={onClose}>
      <TransactionForm data={data} initialProjectId={initialProjectId} initialType={initialType} onSave={onSave} />
    </Modal>
  );
}

function TransactionForm({ data, initialProjectId, initialType, compact = false, onSave }) {
  const [form, setForm] = useState({
    date: today(),
    type: initialType || "Material Purchase",
    amount: 245000,
    paidBy: "Jayabalaji",
    source: "ICICI Bank",
    vendor: "Sri Murugan Traders",
    notes: "Steel and cement purchase",
    billType: "Vendor Bill",
    attachment: null,
    allocations: [{ projectId: initialProjectId || data.projects[0]?.id, amount: 245000 }],
  });
  const allocationTotal = form.allocations.reduce((sum, item) => sum + Number(item.amount || 0), 0);
  const isValid = Number(form.amount) > 0 && allocationTotal === Number(form.amount) && form.allocations.every((item) => item.projectId && Number(item.amount) >= 0);

  function updateAllocation(index, patch) {
    setForm((current) => ({
      ...current,
      allocations: current.allocations.map((item, itemIndex) => itemIndex === index ? { ...item, ...patch } : item),
    }));
  }

  async function handleFile(file) {
    if (!file) return;
    const dataUrl = await toDataUrl(file);
    setForm((current) => ({
      ...current,
      attachment: {
        name: file.name,
        type: current.billType,
        refNo: file.name.replace(/\.[^/.]+$/, "").slice(0, 16),
        uploadedBy: current.paidBy,
        uploadedAt: current.date,
        dataUrl,
      },
    }));
  }

  function submit(event) {
    event.preventDefault();
    if (!isValid) return;
    onSave({
      date: form.date,
      type: form.type,
      amount: Number(form.amount),
      paidBy: form.paidBy,
      source: form.source,
      vendor: form.vendor || "-",
      notes: form.notes || form.type,
      allocations: form.allocations.map((item) => ({ projectId: item.projectId, amount: Number(item.amount) })),
      attachment: form.attachment,
    });
  }

  return (
    <form className={`finance-form ${compact ? "compact" : ""}`} onSubmit={submit}>
      <div className="form-grid">
        <Input label="Amount (Rs)" type="number" value={form.amount} onChange={(amount) => setForm({ ...form, amount: Number(amount) })} />
        <Select label="Type" value={form.type} onChange={(type) => setForm({ ...form, type })} options={transactionTypes} />
        <Input label="Date" type="date" value={form.date} onChange={(date) => setForm({ ...form, date })} />
        <Select label="Paid By" value={form.paidBy} onChange={(paidBy) => setForm({ ...form, paidBy })} options={people} />
        <Select label="Payment Source" value={form.source} onChange={(source) => setForm({ ...form, source })} options={sources} />
        <Input label="Vendor / Person" value={form.vendor} onChange={(vendor) => setForm({ ...form, vendor })} />
        <Input label="Notes" value={form.notes} onChange={(notes) => setForm({ ...form, notes })} />
        <Select label="Bill Type" value={form.billType} onChange={(billType) => setForm({ ...form, billType })} options={billTypes} />
      </div>
      <label className="file-input">
        <input type="file" onChange={(event) => handleFile(event.target.files?.[0])} />
        <Paperclip size={17} />
        {form.attachment ? <span>{form.attachment.name}</span> : <span>Bill / Attachment</span>}
      </label>
      <div className="allocations">
        <div className="allocation-head">
          <strong>Allocate to Projects</strong>
          <span className={allocationTotal === Number(form.amount) ? "positive" : "danger"}>{formatMoney(allocationTotal)} / {formatMoney(form.amount)}</span>
        </div>
        {form.allocations.map((allocation, index) => (
          <div className="allocation-row" key={`${allocation.projectId}-${index}`}>
            <Select value={allocation.projectId} onChange={(projectId) => updateAllocation(index, { projectId })} options={data.projects.map((project) => ({ label: project.name, value: project.id }))} />
            <Input type="number" value={allocation.amount} onChange={(amount) => updateAllocation(index, { amount: Number(amount) })} />
            <button type="button" title="Remove" onClick={() => setForm((current) => ({ ...current, allocations: current.allocations.filter((_, itemIndex) => itemIndex !== index) }))} disabled={form.allocations.length === 1}><X size={15} /></button>
          </div>
        ))}
        <button type="button" className="add-row" onClick={() => setForm((current) => ({ ...current, allocations: [...current.allocations, { projectId: data.projects[0]?.id, amount: 0 }] }))}><Plus size={15} />Add Project</button>
        <div className={`validation ${isValid ? "ok" : "bad"}`}>
          {isValid ? <CheckCircle2 size={16} /> : <X size={16} />}
          {isValid ? "Allocation total matches amount." : "Allocation total must equal payment total."}
        </div>
      </div>
      <button className="save-button" type="submit" disabled={!isValid}>Save Transaction</button>
    </form>
  );
}

function BillModal({ projects, onClose, onSave }) {
  const [form, setForm] = useState({ projectId: projects[0]?.id, type: "Vendor Bill", uploadedBy: "Kumaresh", uploadedAt: today(), name: "", dataUrl: "" });
  async function handleFile(file) {
    if (!file) return;
    const dataUrl = await toDataUrl(file);
    setForm((current) => ({ ...current, name: file.name, dataUrl }));
  }
  return (
    <Modal title="Upload Bill" onClose={onClose}>
      <form className="finance-form" onSubmit={(event) => { event.preventDefault(); if (form.name) onSave(form); }}>
        <div className="form-grid">
          <Select label="Project" value={form.projectId} onChange={(projectId) => setForm({ ...form, projectId })} options={projects.map((project) => ({ label: project.name, value: project.id }))} />
          <Select label="Type" value={form.type} onChange={(type) => setForm({ ...form, type })} options={billTypes} />
          <Select label="Uploaded By" value={form.uploadedBy} onChange={(uploadedBy) => setForm({ ...form, uploadedBy })} options={people} />
          <Input label="Date" type="date" value={form.uploadedAt} onChange={(uploadedAt) => setForm({ ...form, uploadedAt })} />
        </div>
        <label className="file-input"><input type="file" onChange={(event) => handleFile(event.target.files?.[0])} /><Upload size={17} /><span>{form.name || "Choose file"}</span></label>
        <button className="save-button" type="submit" disabled={!form.name}>Save Bill</button>
      </form>
    </Modal>
  );
}

function VariationModal({ projects, initialProjectId, onClose, onSave }) {
  const [form, setForm] = useState({ projectId: initialProjectId || projects[0]?.id, type: "Extra Work", description: "Client requested upgrade", amount: 250000, status: "Pending", refNo: "" });
  return (
    <Modal title="Add Variation" onClose={onClose}>
      <form className="finance-form" onSubmit={(event) => { event.preventDefault(); onSave({ ...form, amount: Number(form.amount), attachment: null }); }}>
        <div className="form-grid">
          <Select label="Project" value={form.projectId} onChange={(projectId) => setForm({ ...form, projectId })} options={projects.map((project) => ({ label: project.name, value: project.id }))} />
          <Select label="Type" value={form.type} onChange={(type) => setForm({ ...form, type })} options={variationTypes} />
          <Input label="Description" value={form.description} onChange={(description) => setForm({ ...form, description })} />
          <Input label="Amount" type="number" value={form.amount} onChange={(amount) => setForm({ ...form, amount: Number(amount) })} />
          <Select label="Status" value={form.status} onChange={(status) => setForm({ ...form, status })} options={["Pending", "Approved", "Collected"]} />
          <Input label="Reference" value={form.refNo} onChange={(refNo) => setForm({ ...form, refNo })} />
        </div>
        <button className="save-button" type="submit">Save Variation</button>
      </form>
    </Modal>
  );
}

function ProjectModal({ onClose, onSave }) {
  const [form, setForm] = useState({ name: "", client: "", code: "", site: "", contractValue: 1000000, status: "Upcoming" });
  return (
    <Modal title="Add Project" onClose={onClose}>
      <form className="finance-form" onSubmit={(event) => { event.preventDefault(); if (form.name && form.client) onSave({ ...form, contractValue: Number(form.contractValue) }); }}>
        <div className="form-grid">
          <Input label="Project Name" value={form.name} onChange={(name) => setForm({ ...form, name })} />
          <Input label="Client Name" value={form.client} onChange={(client) => setForm({ ...form, client })} />
          <Input label="Project Code" value={form.code} onChange={(code) => setForm({ ...form, code })} />
          <Input label="Site" value={form.site} onChange={(site) => setForm({ ...form, site })} />
          <Input label="Original Contract Value" type="number" value={form.contractValue} onChange={(contractValue) => setForm({ ...form, contractValue: Number(contractValue) })} />
          <Select label="Status" value={form.status} onChange={(status) => setForm({ ...form, status })} options={["Upcoming", "Pending", "In Progress"]} />
        </div>
        <button className="save-button" type="submit" disabled={!form.name || !form.client}>Save Project</button>
      </form>
    </Modal>
  );
}

function Modal({ title, children, onClose }) {
  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true">
      <section className="modal">
        <div className="modal-head">
          <h2>{title}</h2>
          <button onClick={onClose} title="Close"><X size={18} /></button>
        </div>
        {children}
      </section>
    </div>
  );
}

function Select({ label, value, onChange, options }) {
  const normalized = options.map((option) => typeof option === "string" ? { label: option, value: option } : option);
  return (
    <label className="field">
      {label && <span>{label}</span>}
      <select value={value} onChange={(event) => onChange(event.target.value)}>
        {normalized.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
      </select>
    </label>
  );
}

function Input({ label, icon: Icon, value, onChange, ...props }) {
  return (
    <label className="field">
      {label && <span>{label}</span>}
      <span className={Icon ? "input-with-icon" : ""}>
        {Icon && <Icon size={16} />}
        <input value={value} onChange={(event) => onChange(event.target.value)} {...props} />
      </span>
    </label>
  );
}

function MobileNav({ activeNav, setActiveNav, openQuick }) {
  const items = [["Dashboard", Home], ["Projects", Building2], ["Transactions", SlidersHorizontal], ["Bills", FileText], ["More", Menu]];
  return (
    <nav className="mobile-nav">
      {items.map(([label, Icon]) => (
        <button key={label} className={activeNav === label ? "active" : ""} onClick={() => label === "More" ? openQuick() : setActiveNav(label)}>
          <Icon size={18} />
          <span>{label}</span>
        </button>
      ))}
    </nav>
  );
}

function Empty({ label }) {
  return <div className="empty">{label}</div>;
}

function toDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

export { App };
