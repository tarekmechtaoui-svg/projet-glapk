# Multi-Hotel Support Implementation

## Database Approach

### Schema Design

The database has been restructured to support multiple hotels:

#### 1. **Hotels Table**
```sql
- id (uuid, primary key)
- name (text, required)
- description (text)
- address (text)
- rating (decimal 2,1) - Range: 0.0 to 5.0
- image_url (text) - External URL to hotel image
- created_at (timestamptz)
```

#### 2. **Rooms Table** (Updated)
```sql
- id (uuid, primary key)
- hotel_id (uuid, required, foreign key to hotels)
- number (text, required)
- category (text)
- beds (integer)
- price (decimal)
- created_at (timestamptz)
```

#### 3. **Persons Table** (Unchanged)
```sql
- id (uuid, primary key)
- supabase_user_id (uuid, foreign key to auth.users)
- first_name (text, required)
- last_name (text)
- phone (text)
- created_at (timestamptz)
```

#### 4. **Reservations Table** (Unchanged)
```sql
- id (uuid, primary key)
- person_id (uuid, required, foreign key to persons)
- room_id (uuid, required, foreign key to rooms)
- start_date (date, required)
- end_date (date, required)
- status (text) - Values: confirmed, cancelled, completed
- created_at (timestamptz)
```

### Row Level Security (RLS)

All tables have RLS enabled with appropriate policies:

- **Hotels**: Public read access (anyone can browse)
- **Rooms**: Public read access (anyone can browse)
- **Persons**: Users can only read their own data
- **Reservations**: Users can only read their own reservations

### Sample Data

The database includes 3 sample hotels:

1. **Grand Palace Hotel** (Paris) - 4.8 stars
2. **Seaside Resort & Spa** (Miami) - 4.6 stars
3. **Mountain View Lodge** (Chamonix) - 4.4 stars

Each hotel has 4 sample rooms with varying categories and prices.

## Hotel Pictures Approach

### Image Storage Strategy

Hotel pictures are **NOT stored in the database**. Instead:

1. **Image URLs** are stored in the `image_url` column of the `hotels` table
2. Images are hosted externally on **Pexels** (free stock photo service)
3. The app loads images directly from these URLs using Flutter's `Image.network()` widget

### Benefits of This Approach

- **No Database Bloat**: Images don't consume database storage
- **Better Performance**: Direct CDN delivery from Pexels
- **Cost Effective**: No storage costs for images
- **Easy Updates**: Change image URL to update hotel picture
- **Scalability**: No limits on image sizes or quantities

### Adding New Hotel Images

To add images for new hotels:

1. Find high-quality hotel images on [Pexels.com](https://www.pexels.com)
2. Right-click the image and copy the image URL
3. Use the URL in the `image_url` field when inserting/updating hotels

Example URLs used:
- Grand Palace: `https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg`
- Seaside Resort: `https://images.pexels.com/photos/1058759/pexels-photo-1058759.jpeg`
- Mountain Lodge: `https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg`

### Alternative Image Sources

You can also use:
- **Unsplash**: Free high-quality images
- **Your own CDN**: Upload to a cloud storage service (AWS S3, Cloudflare R2, etc.)
- **Supabase Storage**: If you prefer, you can use Supabase's storage bucket and store image URLs

## App Flow

1. **Hotels List Screen** - Displays all hotels with images and ratings
2. **Rooms List Screen** - Shows rooms for selected hotel with hotel banner
3. **Reservation Form** - Books a specific room with date selection
4. **My Reservations** - View all user reservations

## Key Features

- Modern card-based UI design
- Hotel images loaded from external URLs
- Star rating display (visual stars + numeric rating)
- Filtered room listings by hotel
- Expandable hotel header with parallax effect
- Responsive design with proper loading states
- Error handling for failed image loads

## Technical Implementation

### Models
- `Hotel` model with rating and imageUrl properties
- `Room` model updated with hotelId reference

### Services
- `getHotels()` - Fetch all hotels sorted by rating
- `getHotelById(id)` - Fetch specific hotel
- `getRooms(hotelId)` - Fetch rooms filtered by hotel

### UI Components
- `HotelsListScreen` - Grid/list of hotels with images
- `RoomsListScreen` - Hotel-specific room listings with SliverAppBar
- Modern card designs with shadows and rounded corners
- Blue color scheme for professional appearance
