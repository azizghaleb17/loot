-- Loot — reference seed for a fresh Supabase project.
-- Mirrors the demo app's fixed dimensions (lib/features/catalog/data/seed_data.dart).
-- The 48-product demo catalog is seeded through Supabase Studio / CSV import in
-- Phase 1 real-backend setup (spec task #5) with real photography; the Dart seed
-- file is the source list to transcribe.

insert into age_groups (slug, label, label_ar, min_months, max_months, sort_order) values
  ('0-12m',   '0–12 months', '٠–١٢ شهرًا',  0,   12,  0),
  ('1-2',     '1–2 years',   '١–٢ سنة',    12,  36,  1),
  ('3-5',     '3–5 years',   '٣–٥ سنوات',  36,  72,  2),
  ('6-8',     '6–8 years',   '٦–٨ سنوات',  72,  108, 3),
  ('9-12',    '9–12 years',  '٩–١٢ سنة',   108, 156, 4),
  ('12-plus', '12+ years',   '+١٢ سنة',    156, null, 5);

insert into categories (slug, name, name_ar, icon, sort_order) values
  ('building-blocks', 'Building & Blocks',  'مكعبات وبناء',        '🧱', 0),
  ('dolls-plush',     'Dolls & Plush',      'دمى وألعاب قطنية',    '🧸', 1),
  ('vehicles',        'Cars & Vehicles',    'سيارات ومركبات',      '🚗', 2),
  ('puzzles',         'Puzzles',            'ألغاز وتركيب',        '🧩', 3),
  ('arts-crafts',     'Arts & Crafts',      'فنون وأشغال',         '🎨', 4),
  ('outdoor',         'Outdoor & Sports',   'ألعاب خارجية ورياضة', '⚽', 5),
  ('educational',     'Educational & STEM', 'تعليمية وعلوم',       '🔬', 6),
  ('board-games',     'Board Games',        'ألعاب لوحية',         '🎲', 7),
  ('baby-toddler',    'Baby & Toddler',     'رضّع وأطفال صغار',    '🍼', 8),
  ('action-figures',  'Action Figures',     'شخصيات وأبطال',       '🦸', 9);

insert into brands (slug, name, name_ar) values
  ('lego', 'LEGO', 'ليغو'),
  ('fisher-price', 'Fisher-Price', 'فيشر برايس'),
  ('play-doh', 'Play-Doh', 'بلاي دوه'),
  ('hot-wheels', 'Hot Wheels', 'هوت ويلز'),
  ('barbie', 'Barbie', 'باربي'),
  ('melissa-doug', 'Melissa & Doug', 'ميليسا آند دوغ'),
  ('vtech', 'VTech', 'في تك'),
  ('ravensburger', 'Ravensburger', 'رافنسبورغر'),
  ('hasbro', 'Hasbro', 'هاسبرو'),
  ('chicco', 'Chicco', 'شيكو'),
  ('crayola', 'Crayola', 'كرايولا'),
  ('nerf', 'Nerf', 'نيرف');

-- Promotions — must match lib/features/cart/domain/cart.dart demoPromos.
insert into promotions (code, type, value, min_order_fils, is_active) values
  ('LOOT10',   'percent',       10, 0,    true),
  ('FREESHIP', 'free_shipping', 0,  5000, true);
