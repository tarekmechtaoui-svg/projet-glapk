# How to Add Hotel Images

This guide explains how to add images for your hotels without storing them in the database.

## Option 1: Using Pexels (Recommended - Free)

1. **Go to Pexels.com**
   - Visit https://www.pexels.com
   - Search for "hotel", "resort", "luxury hotel", etc.

2. **Find Your Image**
   - Browse and select a high-quality hotel image
   - Click on the image to open it in full view

3. **Copy the Image URL**
   - Right-click on the image
   - Select "Copy Image Address" or "Copy Image Link"
   - The URL should look like: `https://images.pexels.com/photos/XXXXXX/pexels-photo-XXXXXX.jpeg`

4. **Add to Your Hotel**
   - Insert the URL in the `image_url` field when creating/updating a hotel
   - Example SQL:
   ```sql
   INSERT INTO hotels (name, description, address, rating, image_url)
   VALUES (
     'Your Hotel Name',
     'Hotel description',
     'Hotel address',
     4.5,
     'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg'
   );
   ```

## Option 2: Using Unsplash (Free)

1. Visit https://unsplash.com
2. Search for hotel images
3. Click on an image
4. Click "..." → "Copy Image Address"
5. Use the URL in your hotel's `image_url` field

## Option 3: Using Your Own Images

### A. Upload to Cloud Storage

1. **Upload to a service like:**
   - AWS S3
   - Cloudflare R2
   - Google Cloud Storage
   - Azure Blob Storage

2. **Make the image publicly accessible**
   - Set appropriate permissions for public read access

3. **Copy the public URL**
   - Use this URL in the `image_url` field

### B. Using Supabase Storage

1. **Create a storage bucket in Supabase:**
   ```sql
   -- Create a public bucket for hotel images
   INSERT INTO storage.buckets (id, name, public)
   VALUES ('hotel-images', 'hotel-images', true);
   ```

2. **Upload your image through Supabase dashboard:**
   - Go to Storage in your Supabase project
   - Upload images to the `hotel-images` bucket

3. **Get the public URL:**
   - The URL will be: `https://[your-project-ref].supabase.co/storage/v1/object/public/hotel-images/[filename]`

4. **Use this URL in your hotel record**

## Tips for Best Results

### Image Specifications
- **Format**: JPG or PNG
- **Minimum Size**: 1200px wide for best quality
- **Aspect Ratio**: 16:9 or 4:3 works best
- **File Size**: Keep under 500KB for fast loading

### Image Selection
- Choose high-quality, professional photos
- Ensure good lighting and composition
- Avoid watermarked images (unless you have rights)
- Select images that match your hotel's style

### Testing Your Images
Before adding an image URL to the database, test it:
1. Open the URL in a browser
2. Verify the image loads correctly
3. Check that it's not broken or expired

## Example: Complete Hotel Insert

```sql
INSERT INTO hotels (name, description, address, rating, image_url)
VALUES (
  'Oceanview Paradise Resort',
  'Stunning beachfront resort with infinity pools and world-class amenities',
  '789 Coastal Highway, Malibu, CA, USA',
  4.7,
  'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg'
);
```

## Updating Existing Hotels

To add or change an image for an existing hotel:

```sql
UPDATE hotels
SET image_url = 'https://images.pexels.com/photos/YOUR-IMAGE-ID/pexels-photo-YOUR-IMAGE-ID.jpeg'
WHERE id = 'your-hotel-id';
```

## Troubleshooting

### Image Not Loading
- Verify the URL is accessible in a browser
- Check for HTTPS (some sources require it)
- Ensure the URL ends with image extension (.jpg, .jpeg, .png)

### Image Quality Poor
- Use larger source images (1200px+ width)
- Choose high-resolution photos from Pexels or Unsplash
- Avoid heavily compressed images

### CORS Errors
- Pexels and Unsplash handle CORS correctly
- If using your own storage, ensure CORS headers are set
- Supabase Storage automatically handles CORS
