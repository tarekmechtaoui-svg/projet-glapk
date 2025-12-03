/*
  # Create Initial Database Schema with Multi-Hotel Support

  1. New Tables
    - `hotels`
      - `id` (uuid, primary key)
      - `name` (text, required) - Hotel name
      - `description` (text) - Hotel description
      - `address` (text) - Hotel address
      - `rating` (decimal) - Hotel rating (0-5 stars)
      - `image_url` (text) - URL to hotel image (external link)
      - `created_at` (timestamptz) - Creation timestamp

    - `rooms`
      - `id` (uuid, primary key)
      - `hotel_id` (uuid, required) - Foreign key to hotels
      - `number` (text, required) - Room number
      - `category` (text) - Room category (standard, deluxe, suite, etc.)
      - `beds` (integer) - Number of beds
      - `price` (decimal) - Price per night
      - `created_at` (timestamptz) - Creation timestamp

    - `persons`
      - `id` (uuid, primary key)
      - `supabase_user_id` (uuid) - Link to auth.users (optional)
      - `first_name` (text, required) - First name
      - `last_name` (text) - Last name
      - `phone` (text) - Phone number
      - `created_at` (timestamptz) - Creation timestamp

    - `reservations`
      - `id` (uuid, primary key)
      - `person_id` (uuid, required) - Foreign key to persons
      - `room_id` (uuid, required) - Foreign key to rooms
      - `start_date` (date, required) - Check-in date
      - `end_date` (date, required) - Check-out date
      - `status` (text) - Reservation status (confirmed, cancelled, completed)
      - `created_at` (timestamptz) - Creation timestamp

  2. Security
    - Enable RLS on all tables
    - Hotels: Public read access (anyone can browse hotels)
    - Rooms: Public read access (anyone can browse rooms)
    - Persons: Users can only read their own data
    - Reservations: Users can only read their own reservations

  3. Sample Data
    - 3 hotels with real Pexels image URLs
    - Sample rooms for each hotel

  4. Notes
    - Hotel images stored as external URLs (not in database)
    - Rating uses decimal(2,1) for precision (e.g., 4.5)
    - All foreign keys have CASCADE delete for data integrity
*/

-- Create hotels table
CREATE TABLE IF NOT EXISTS hotels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  address text,
  rating decimal(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- Create rooms table
CREATE TABLE IF NOT EXISTS rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hotel_id uuid NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
  number text NOT NULL,
  category text,
  beds integer DEFAULT 1 CHECK (beds > 0),
  price decimal(10,2) DEFAULT 0.0 CHECK (price >= 0),
  created_at timestamptz DEFAULT now()
);

-- Create persons table
CREATE TABLE IF NOT EXISTS persons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supabase_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name text NOT NULL,
  last_name text,
  phone text,
  created_at timestamptz DEFAULT now()
);

-- Create reservations table
CREATE TABLE IF NOT EXISTS reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  person_id uuid NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  start_date date NOT NULL,
  end_date date NOT NULL,
  status text DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'completed')),
  created_at timestamptz DEFAULT now(),
  CHECK (end_date >= start_date)
);

-- Enable RLS on all tables
ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE persons ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Hotels: Public read access
CREATE POLICY "Anyone can view hotels"
  ON hotels
  FOR SELECT
  TO public
  USING (true);

-- Rooms: Public read access
CREATE POLICY "Anyone can view rooms"
  ON rooms
  FOR SELECT
  TO public
  USING (true);

-- Persons: Users can read their own data
CREATE POLICY "Users can view own profile"
  ON persons
  FOR SELECT
  TO authenticated
  USING (auth.uid() = supabase_user_id);

-- Persons: Anyone can create (for guest reservations)
CREATE POLICY "Anyone can create person"
  ON persons
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Reservations: Users can view their own reservations
CREATE POLICY "Users can view own reservations"
  ON reservations
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM persons
      WHERE persons.id = reservations.person_id
      AND persons.supabase_user_id = auth.uid()
    )
  );

-- Reservations: Anyone can create (for guest reservations)
CREATE POLICY "Anyone can create reservations"
  ON reservations
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Insert sample hotels with Pexels images
INSERT INTO hotels (id, name, description, address, rating, image_url) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Grand Palace Hotel', 'Luxury 5-star hotel in the heart of the city with exceptional service, fine dining, and premium amenities. Experience elegance and sophistication.', '123 Avenue des Champs-Élysées, Paris, France', 4.8, 'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Seaside Resort & Spa', 'Beautiful beachfront resort with stunning ocean views, world-class spa facilities, and direct beach access. Perfect for relaxation and luxury.', '456 Ocean Drive, Miami Beach, FL, USA', 4.6, 'https://images.pexels.com/photos/1058759/pexels-photo-1058759.jpeg'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Mountain View Lodge', 'Cozy mountain retreat perfect for nature lovers and adventure seekers. Enjoy hiking, skiing, and breathtaking alpine views.', '789 Route des Alpes, Chamonix-Mont-Blanc, France', 4.4, 'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg')
ON CONFLICT (id) DO NOTHING;

-- Insert sample rooms for Grand Palace Hotel
INSERT INTO rooms (hotel_id, number, category, beds, price) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', '101', 'Standard', 1, 150.00),
  ('550e8400-e29b-41d4-a716-446655440001', '102', 'Standard', 2, 200.00),
  ('550e8400-e29b-41d4-a716-446655440001', '201', 'Deluxe', 2, 300.00),
  ('550e8400-e29b-41d4-a716-446655440001', '301', 'Suite', 3, 500.00);

-- Insert sample rooms for Seaside Resort
INSERT INTO rooms (hotel_id, number, category, beds, price) VALUES
  ('550e8400-e29b-41d4-a716-446655440002', 'A1', 'Ocean View', 2, 250.00),
  ('550e8400-e29b-41d4-a716-446655440002', 'A2', 'Ocean View', 2, 250.00),
  ('550e8400-e29b-41d4-a716-446655440002', 'B1', 'Beachfront Suite', 3, 450.00),
  ('550e8400-e29b-41d4-a716-446655440002', 'P1', 'Penthouse', 4, 800.00);

-- Insert sample rooms for Mountain View Lodge
INSERT INTO rooms (hotel_id, number, category, beds, price) VALUES
  ('550e8400-e29b-41d4-a716-446655440003', '1', 'Cabin', 2, 120.00),
  ('550e8400-e29b-41d4-a716-446655440003', '2', 'Cabin', 2, 120.00),
  ('550e8400-e29b-41d4-a716-446655440003', '3', 'Chalet', 4, 280.00),
  ('550e8400-e29b-41d4-a716-446655440003', '4', 'Mountain Suite', 3, 220.00);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_rooms_hotel_id ON rooms(hotel_id);
CREATE INDEX IF NOT EXISTS idx_persons_supabase_user_id ON persons(supabase_user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_person_id ON reservations(person_id);
CREATE INDEX IF NOT EXISTS idx_reservations_room_id ON reservations(room_id);
CREATE INDEX IF NOT EXISTS idx_reservations_dates ON reservations(start_date, end_date);