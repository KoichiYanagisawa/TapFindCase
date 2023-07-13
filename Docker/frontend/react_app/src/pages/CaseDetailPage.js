import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

function ProductDetailPage() {
  const [product, setProduct] = useState(null);
  const { id } = useParams();

  useEffect(() => {
    fetch(`http://localhost:3000/products/detail/${id}`)
      .then(response => response.json())
      .then(data => setProduct(data));
  }, [id]);

  if (!product) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h2>{product.product.name}</h2>
      <p>{product.product.color}</p>
      <p>{product.product.price}</p>
      {/* Add product description and image */}
      <img src={`data:image/jpeg;base64,${product.images}`} alt={product.name} />
    </div>
  );
}

export default ProductDetailPage;
