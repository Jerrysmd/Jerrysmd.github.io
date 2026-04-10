# Jerryskills

Jerryskills is a personal blog and knowledge base built with [Hugo](https://gohugo.io/) and the [DoIt](https://github.com/HEIGE-PCloud/DoIt) theme, and published on [jerrysmd.github.io](https://jerrysmd.github.io/).

The site is used to document long-form technical notes, project write-ups, reading traces, and personal explorations. The content spans software engineering, distributed systems, backend infrastructure, Java, Spring, Spark, ClickHouse, networking, finance-related topics, and occasional non-technical posts around books, photography, and life.

## Overview

- Static site generator: Hugo
- Theme: DoIt (managed as a git submodule)
- Hosting: GitHub Pages
- Search: Algolia DocSearch index upload via GitHub Actions
- Content format: Markdown bundles under `content/posts`
- Current scale: 90+ post bundles

## Repository Structure

```text
.
├── archetypes/         # Hugo content templates
├── assets/             # Custom styles, icons, and data files
├── config/             # Hugo and theme configuration
├── content/            # About page and all blog posts
├── static/             # Favicons and static assets
├── themes/DoIt/        # Theme submodule
├── createBlog.sh       # Helper script to create a new post bundle
└── localserver.sh      # Helper script to run the local Hugo server
```

## Content Focus

This repository mainly contains:

- Deep-dive technical articles
- Engineering notes and architecture summaries
- Tooling and productivity write-ups
- Reading and learning records
- Personal side projects and experiments

Representative topics in the existing posts include QUIC, JDK 21, vector databases, Maven, Spark optimization, ClickHouse, Spring, internationalization design, browser extensions, and more.

## Local Development

### 1. Clone the repository

```bash
git clone --recurse-submodules https://github.com/Jerrysmd/Jerrysmd.github.io.git
cd Jerrysmd.github.io
```

If you already cloned it without submodules:

```bash
git submodule update --init --recursive
```

### 2. Install Hugo

This site is built with Hugo Extended. The GitHub Actions workflow currently uses `hugo 0.146.5`, so using the same or a compatible Extended version is recommended.

### 3. Run the site locally

```bash
./localserver.sh
```

This runs:

```bash
hugo server --disableFastRender
```

The local site will usually be available at `http://localhost:1313`.

## Writing a New Post

You can create a new post bundle with the helper script:

```bash
./createBlog.sh
```

The script generates a post in this format:

```text
content/posts/YYYYMMDD_post-name/index.md
```

This keeps each article and its related images/assets in the same directory, which works well for Hugo page bundles.

## Build

To generate the production site locally:

```bash
hugo --minify
```

The generated files will be written to `public/`.

## Deployment

Deployment is handled by GitHub Actions in `.github/workflows/gh-pages.yml`.

- Pushes to the `blog-source` branch trigger the site build
- Hugo builds the site into `public/`
- The generated output is published to `gh-pages`
- After deployment, the search index is uploaded to Algolia

## License

Unless otherwise noted, the site content is published under `CC BY-NC 4.0`.

## Links

- Website: [https://jerrysmd.github.io/](https://jerrysmd.github.io/)
- Repository: [https://github.com/Jerrysmd/Jerrysmd.github.io](https://github.com/Jerrysmd/Jerrysmd.github.io)
