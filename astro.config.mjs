import { defineConfig } from 'astro/config';
import tailwind from "@astrojs/tailwind";
import htmx from 'astro-htmx';
import alpinejs from "@astrojs/alpinejs";

export default defineConfig({
  integrations: [tailwind(), htmx(), alpinejs()]
});
