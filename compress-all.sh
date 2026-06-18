find assets -type f \
  \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) \
  -print0 | while IFS= read -r -d '' file; do

    rel="${file#assets/}"
    dest="assets-optimized/${rel%.*}.jpg"

    mkdir -p "$(dirname "$dest")"

    magick "$file" \
      -resize '750x1125>' \
      -strip \
      -quality 80 \
      "$dest"
done
