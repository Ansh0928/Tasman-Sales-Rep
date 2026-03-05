"use client";

import { useEffect, useRef } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

// Fix default icon paths for Next.js / bundlers
delete (L.Icon.Default.prototype as unknown as { _getIconUrl?: unknown })._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
});

interface Entry {
  id: string;
  company_name: string;
  contact_person: string;
  latitude: number;
  longitude: number;
  notes: string;
  visit_date: string;
}

export default function MapView({ entries }: { entries: Entry[] }) {
  const mapRef = useRef<L.Map | null>(null);
  const markersRef = useRef<L.Marker[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;

    mapRef.current = L.map(containerRef.current).setView([-37.8136, 144.9631], 10);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(mapRef.current);
  }, []);

  useEffect(() => {
    if (!mapRef.current) return;

    // Clear existing markers
    markersRef.current.forEach((m) => mapRef.current?.removeLayer(m));
    markersRef.current = [];

    if (entries.length === 0) return;

    const bounds: L.LatLngTuple[] = [];

    entries.forEach((e) => {
      if (e.latitude == null || e.longitude == null || isNaN(e.latitude) || isNaN(e.longitude)) return;

      const marker = L.marker([e.latitude, e.longitude]).addTo(mapRef.current!);
      const date = new Date(e.visit_date);
      marker.bindPopup(`
        <strong>${e.company_name}</strong><br>
        Contact: ${e.contact_person}<br>
        ${date.toLocaleDateString("en-AU")}<br>
        ${e.notes ? "<em>" + e.notes + "</em>" : ""}
      `);
      markersRef.current.push(marker);
      bounds.push([e.latitude, e.longitude]);
    });

    if (bounds.length > 0) {
      mapRef.current.fitBounds(bounds, { padding: [30, 30] });
    }
  }, [entries]);

  return (
    <div
      ref={containerRef}
      style={{ width: "100%", height: "100%", minHeight: 300 }}
    />
  );
}
