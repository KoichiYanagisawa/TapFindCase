import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

function CaseListPage() {
  const [cases, setCases] = useState([]);
  const { model } = useParams();

  useEffect(() => {
    fetch(`http://localhost:3000/products/${model}`)
      .then(response => response.json())
      .then(data => setCases(data));
  }, [model]);

  return (
    <div>
      {cases.map((caseItem, index) => (
        <div key={index}>
          <h2>{caseItem.name}</h2>
          <p>{caseItem.price}</p>
        </div>
      ))}
    </div>
  );
}

export default CaseListPage;
