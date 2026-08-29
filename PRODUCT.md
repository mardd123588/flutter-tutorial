# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

- VitePress 1.6.4 and Vue 3.5.42 for the public tutorial site.
- Flutter 3.47.0 and Dart 3.13.0 for all teaching applications.
- GitHub Pages serves the site and independent Flutter Web previews under `/flutter-tutorial/`.

## Users

The primary reader can already use Dart and has experience with at least one other programming language. They want a structured Flutter course for first study and a compact reference they can return to while building applications.

## Product Purpose

The tutorial teaches Flutter framework behavior, application design, testing, debugging, performance, and delivery as one connected learning path. Readers learn concepts through verified code and use independent projects to prove that they can apply each group of skills.

Success means a reader can design, implement, test, diagnose, and publish a medium-sized Flutter application, while understanding which conclusions were verified only on Web and which still require native-platform work.

## Positioning

Every chapter declares its knowledge dependencies, every runnable example comes from analyzed or tested source, and each top-level part ends with one self-contained project. The tutorial keeps framework explanation and real application work together without turning the course into a long project walkthrough.

## Operating Context

- Readers can follow the 58-chapter sequence or enter through a knowledge index when reviewing a topic.
- Tutorial pages link to tested source, an independent Flutter Web preview, relevant projects, common errors, and primary references.
- Chapter progress stays in the current browser and can be exported, imported, or cleared.
- Project previews run as separate Flutter Web applications rather than embedded runtimes inside article pages.

## Capabilities and Constraints

- The first release contains eight top-level parts, eight capstone projects, and five focus projects.
- Flutter 3.47.0, Dart 3.13.0, Node.js 22 LTS in CI, and VitePress 1.6.4 are the version baseline.
- Every project must pass analyze, unit tests, Widget tests, Chrome integration tests, and a release Web build.
- Projects are independent and do not share business code or a UI package.
- Network examples include deterministic fixtures and do not depend on a remote service in CI.
- The public site uses local search and GitHub Issues for content reports.
- The first release has no accounts, cloud sync, comments, PWA, online editor, analytics, advertising, social widgets, or third-party fonts.
- Native-only capabilities are extension material and are not presented as Web-verified projects.

## Brand Commitments

- Public content is written in Chinese. API names, commands, paths, code identifiers, and error text remain in English.
- Writing follows the local `shuorenhua` skill in its documentation mode: direct, compact, technically precise, and free of promotional filler.
- The site is an independent tutorial, not a Google or Flutter official property. Flutter trademarks remain attributed to Google LLC.
- Projects and illustrations are original. Official examples may establish facts and boundaries but do not supply the product concept, interface, data, or code structure.

## Evidence on Hand

- Primary-source research is stored in `docs/research/`.
- Long-lived decisions are stored in `docs/adr/`.
- Flutter Web probes in `.scratch/stack_probe` have verified Riverpod 3, go_router 18, Drift 2.34.3, hash routing, subpath release builds, persistence, and ChromeDriver integration tests.
- The complete first-release specification is GitHub Issue #1.
- No testimonials, usage metrics, learner outcomes, or third-party endorsements exist and must not be invented.

## Product Principles

1. Teach the mechanism when it changes design or debugging decisions; keep one-off API usage short.
2. Introduce concepts in dependency order and explain unavoidable early appearances once.
3. Make runnable source, tests, screenshots, and prose describe the same behavior.
4. Use projects to verify learning without letting a project replace the chapter's explanation.
5. State platform, version, data, and testing boundaries wherever they affect a conclusion.

## Accessibility & Inclusion

The VitePress site and Flutter Web previews use WCAG 2.2 AA as their design and acceptance target. Keyboard access, visible focus, semantic structure, contrast, text scaling, narrow screens, reduced motion, and understandable errors are required throughout the course.
