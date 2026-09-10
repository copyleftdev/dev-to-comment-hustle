# Hero image provenance

> [!IMPORTANT]
> `hero.jpg`, `hero-full.jpg` and `hero-cover-devto.jpg` are an **AI-generated
> illustration**. They are artwork for the article, **not evidence**, and nothing in
> them depicts a real person, place, or system. Every factual claim in this repository
> is backed by a raw capture in [`evidence/raw/`](../evidence/raw) instead.

The one genuine artifact in `assets/` is [`wombat-avatar.png`](wombat-avatar.png) —
the actual profile image used by the spam account, retrieved from DEV's public CDN.

## Generation record

| Field | Value |
|---|---|
| Generated | 2026-09-10 |
| Model | `google/gemini-3-pro-image-preview` (Nano Banana Pro) |
| Route | OpenRouter `/api/v1/chat/completions`, `modalities: ["image","text"]` |
| Native output | 5504 × 3072 JPEG |
| Pipeline | text-to-image at 1376×768, then image-to-image refine at `image_size: "4K"` preserving composition |
| Derivatives | `hero.jpg` 2560px · `hero-cover-devto.jpg` 1000×420 |

## Why a wombat in a basement

Every prop is a finding from the investigation rendered as a physical object:

| Prop | Finding |
|---|---|
| The wombat itself | The spam account's actual avatar is a public-domain Victorian wombat engraving |
| Sack of blank name badges | The Faker-generated persona template — 69,164,186,000 possible identities, none of them a person |
| Rubber stamp and ink pad | The inert `whose=` parameter: motion that changes nothing |
| One cheap beige tower | The entire operation is a single budget VPS running one Express route and an MTA |
| Piggy bank with three coins | Break-even is 0.06–2.4 conversions per year — three signups pays for the year |
| Red yarn connecting nothing | Attribution failed; the one lead that looked like a cluster was ruled out |

## Prompts

Initial generation:

```
Weta Workshop practical-effects masterpiece: a hyper-detailed physical creature maquette photographed on a miniature practical set. Macro cinematic photography of a real built model, not a digital illustration.

Subject: a stout, world-weary wombat with the exact stocky silhouette and downturned snout of a Victorian scientific engraving, but realised as a tangible sculpt — individually groomed coarse wiry fur, damp leathery nose, heavy claws, tired half-lidded eyes, subtle silicone skin sheen. It sits hunched on a cracked vinyl office chair that is slightly too small for it, in a cramped dim basement den.

Set: one cheap beige rack server humming with a single amber LED, a rat's nest of ethernet cable, and a boxy CRT monitor whose sickly green-cyan glow is the dominant light source, throwing hard rim light across the wombat's fur and deep shadow behind it.

Satirical miniature set dressing, all physically built: a burlap sack tipped over spilling hundreds of tiny blank paper name badges across the floor; a rubber stamp resting on an ink pad; a chipped ceramic piggy bank with exactly three coins stacked beside it; a corkboard on the wall strung with red yarn that connects to nothing at all.

Lighting and finish: anamorphic cinematic lighting, volumetric haze, floating dust motes, shallow depth of field, deep teal shadows against warm amber practical highlights, tactile real-world imperfections, fingerprints and scuffs on the props. Rich, moody, painterly, gallery-grade.

Absolutely no text, no letters, no numbers, no logos, no signage, no writing of any kind anywhere in the image. 16:9 cinematic widescreen composition.
```

Refinement pass (image-to-image, 4K):

```
Recreate this exact scene at maximum fidelity as a Weta Workshop practical-effects masterpiece.

Preserve precisely: the composition, camera angle, framing, the wombat's pose and expression, the cracked leather office chair, the glowing CRT monitor on the left, the beige tower server with its amber LED, the coiled ethernet cables, the tipped burlap sack spilling blank paper cards, the rubber stamp and ink pad, the chipped piggy bank with stacked coins, the corkboard strung with red yarn, and the teal-and-amber lighting.

Increase only the micro-detail and material realism: individually resolved coarse guard hairs across the wombat's fur with correct clumping and backlit fur fringe, damp leathery nose texture, keratin detail and micro-chips in the claws, dust and fingerprints on the plastic server housing, scuffs and creases in the leather, individual burlap fibres, ceramic crazing on the piggy bank, film grain, dust motes suspended in the volumetric haze, subtle chromatic aberration at the frame edges.

Absolutely no text, no letters, no numbers, no logos, no signage anywhere in the image.
```
