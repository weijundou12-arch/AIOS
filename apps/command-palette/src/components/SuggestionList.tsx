import React from "react";

export function SuggestionList() {
  const suggestions = ["Merge recent PDFs", "Rename screenshots", "Search local notes"];
  return (
    <ul>
      {suggestions.map((item) => <li key={item}>{item}</li>)}
    </ul>
  );
}
