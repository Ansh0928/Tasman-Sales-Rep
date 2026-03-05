import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Tasman Sales Rep - Admin Dashboard",
  description: "Admin dashboard to track sales rep visits",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link
          rel="stylesheet"
          href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        />
      </head>
      <body style={{ margin: 0, fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif", background: "#f5f5f7", color: "#1d1d1f" }}>
        {children}
      </body>
    </html>
  );
}
