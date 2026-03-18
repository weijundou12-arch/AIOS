import React from "react";
import { CommandInput } from "./components/CommandInput";
import { SuggestionList } from "./components/SuggestionList";
import { ProgressTimeline } from "./components/ProgressTimeline";

export default function App() {
  return (
    <main style={{ padding: 24, fontFamily: "sans-serif" }}>
      <h1>AIOS Command Palette</h1>
      <CommandInput />
      <SuggestionList />
      <ProgressTimeline />
    </main>
  );
}
