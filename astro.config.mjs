import { defineConfig } from 'astro/config';

import tailwind from "@astrojs/tailwind";
import htmx from 'astro-htmx';

export default defineConfig({
  integrations: [tailwind(), htmx()]
});
