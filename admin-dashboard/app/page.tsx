"use client";

import { useEffect, useState, useCallback } from "react";
import dynamic from "next/dynamic";

const MapView = dynamic(() => import("./MapView"), { ssr: false });

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";

interface VisitEntry {
  id: string;
  created_at: string;
  company_name: string;
  contact_person: string;
  latitude: number;
  longitude: number;
  notes: string;
  visit_date: string;
  device_id: string;
}

export default function Dashboard() {
  const [entries, setEntries] = useState<VisitEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadEntries = useCallback(async () => {
    if (!SUPABASE_URL || !SUPABASE_KEY) {
      setError("Missing Supabase env: set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY");
      setLoading(false);
      return;
    }
    try {
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/visit_entries?select=*&order=visit_date.desc`,
        {
          headers: {
            apikey: SUPABASE_KEY,
            Authorization: `Bearer ${SUPABASE_KEY}`,
          },
          cache: "no-store",
        }
      );
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setEntries(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadEntries();
    const interval = setInterval(loadEntries, 30000);
    return () => clearInterval(interval);
  }, [loadEntries]);

  const todayCount = entries.filter(
    (e) => new Date(e.visit_date).toDateString() === new Date().toDateString()
  ).length;

  const uniqueCompanies = new Set(entries.map((e) => e.company_name)).size;

  return (
    <div>
      {/* Header */}
      <header style={styles.header}>
        <h1 style={styles.title}>Tasman Sales Rep Dashboard</h1>
        <div style={styles.stats}>
          <div style={styles.stat}>
            <div style={styles.statNumber}>{entries.length}</div>
            <div style={styles.statLabel}>Total Visits</div>
          </div>
          <div style={styles.stat}>
            <div style={styles.statNumber}>{todayCount}</div>
            <div style={styles.statLabel}>Today</div>
          </div>
          <div style={styles.stat}>
            <div style={styles.statNumber}>{uniqueCompanies}</div>
            <div style={styles.statLabel}>Companies</div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div style={styles.container}>
        {/* Map */}
        <div style={styles.mapContainer}>
          <MapView entries={entries} />
        </div>

        {/* Table */}
        <div style={styles.tableContainer}>
          <div style={styles.tableHeader}>
            <h2 style={styles.tableTitle}>Visit Entries</h2>
            <button onClick={loadEntries} style={styles.refreshBtn}>
              Refresh
            </button>
          </div>
          <div style={styles.tableScroll}>
            {loading ? (
              <p style={styles.empty}>Loading...</p>
            ) : error ? (
              <p style={styles.empty}>Error: {error}</p>
            ) : entries.length === 0 ? (
              <p style={styles.empty}>No visits logged yet.</p>
            ) : (
              <table style={styles.table}>
                <thead>
                  <tr>
                    <th style={styles.th}>Company</th>
                    <th style={styles.th}>Contact</th>
                    <th style={styles.th}>Date</th>
                    <th style={styles.th}>Notes</th>
                    <th style={styles.th}>Location</th>
                  </tr>
                </thead>
                <tbody>
                  {entries.map((e) => {
                    const date = new Date(e.visit_date);
                    const dateStr = date.toLocaleDateString("en-AU", {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                    });
                    const timeStr = date.toLocaleTimeString("en-AU", {
                      hour: "2-digit",
                      minute: "2-digit",
                    });
                    const hasCoords =
                      e.latitude != null &&
                      e.longitude != null &&
                      !isNaN(e.latitude) &&
                      !isNaN(e.longitude);
                    const mapsUrl = hasCoords
                      ? `https://www.google.com/maps?q=${e.latitude},${e.longitude}`
                      : "#";

                    return (
                      <tr key={e.id} style={styles.tr}>
                        <td style={styles.td}>
                          <strong>{e.company_name}</strong>
                        </td>
                        <td style={styles.td}>{e.contact_person}</td>
                        <td style={styles.td}>
                          <span style={styles.date}>
                            {dateStr} {timeStr}
                          </span>
                        </td>
                        <td style={styles.td}>
                          <span style={styles.notes}>{e.notes || "-"}</span>
                        </td>
                        <td style={styles.td}>
                          {hasCoords ? (
                            <>
                              <span style={styles.coords}>
                                {e.latitude.toFixed(4)},{" "}
                                {e.longitude.toFixed(4)}
                              </span>
                              <br />
                              <a
                                href={mapsUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                style={styles.mapLink}
                              >
                                Open in Maps
                              </a>
                            </>
                          ) : (
                            "N/A"
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  header: {
    background: "#fff",
    padding: "20px 30px",
    boxShadow: "0 1px 3px rgba(0,0,0,0.1)",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    flexWrap: "wrap",
    gap: "16px",
  },
  title: { fontSize: 22, fontWeight: 600, margin: 0 },
  stats: { display: "flex", gap: 24 },
  stat: { textAlign: "center" as const },
  statNumber: { fontSize: 24, fontWeight: 700, color: "#007aff" },
  statLabel: {
    fontSize: 12,
    color: "#86868b",
    textTransform: "uppercase" as const,
  },
  container: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: 20,
    padding: "20px 30px",
    minHeight: "calc(100vh - 90px)",
    height: "calc(100vh - 90px)",
  },
  mapContainer: {
    borderRadius: 12,
    overflow: "hidden",
    boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
    minHeight: 320,
    height: "100%",
  },
  tableContainer: {
    background: "#fff",
    borderRadius: 12,
    boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
    overflow: "hidden",
    display: "flex",
    flexDirection: "column" as const,
  },
  tableHeader: {
    padding: "16px 20px",
    borderBottom: "1px solid #e5e5e7",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  tableTitle: { fontSize: 16, fontWeight: 600, margin: 0 },
  refreshBtn: {
    background: "#007aff",
    color: "#fff",
    border: "none",
    padding: "8px 16px",
    borderRadius: 8,
    cursor: "pointer",
    fontSize: 13,
  },
  tableScroll: { overflowY: "auto" as const, flex: 1 },
  table: { width: "100%", borderCollapse: "collapse" as const },
  th: {
    background: "#f5f5f7",
    padding: "10px 16px",
    textAlign: "left" as const,
    fontSize: 12,
    fontWeight: 600,
    color: "#86868b",
    textTransform: "uppercase" as const,
    position: "sticky" as const,
    top: 0,
  },
  td: { padding: "12px 16px", borderBottom: "1px solid #f0f0f2", fontSize: 14 },
  tr: {},
  date: { color: "#86868b", fontSize: 12 },
  notes: { color: "#555", fontSize: 13 },
  coords: { fontFamily: "monospace", fontSize: 11, color: "#86868b" },
  mapLink: { color: "#007aff", textDecoration: "none", fontSize: 12 },
  empty: { textAlign: "center" as const, padding: 40, color: "#86868b" },
};
