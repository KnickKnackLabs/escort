/** @jsxImportSource jsx-md */

import { readFileSync, readdirSync } from "fs";
import { join, resolve } from "path";

import {
  Heading, Paragraph, CodeBlock,
  Bold, Code, Link,
  Badge, Badges, Center, Section,
  Table, TableHead, TableRow, Cell,
} from "readme/src/components";

// ── Dynamic data ─────────────────────────────────────────────

const REPO_DIR = resolve(import.meta.dirname);

// Read providers
const providerDir = join(REPO_DIR, "scripts/providers");
const providers = readdirSync(providerDir)
  .filter((f) => f.endsWith(".sh"))
  .map((f) => {
    const content = readFileSync(join(providerDir, f), "utf-8");
    const match = content.match(/^# Dashboard provider: (.+)$/m);
    const outputMatch = content.match(/^# Output: (.+)$/m);
    return {
      name: f.replace(".sh", ""),
      desc: match?.[1] ?? "",
      example: outputMatch?.[1]?.replace(/"/g, "") ?? "",
    };
  })
  .sort((a, b) => a.name.localeCompare(b.name));

// ── README ───────────────────────────────────────────────────

const readme = (
  <>
    <Center>
      <Heading level={1}>escort</Heading>

      <Paragraph>
        <Bold>Predictive context agent for agent workflows.</Bold>
      </Paragraph>

      <Paragraph>
        Richer dashboard providers that plug into{" "}
        <Link href="https://github.com/KnickKnackLabs/hookers">hookers</Link>.{"\n"}
        Know what's happening without asking.
      </Paragraph>

      <Badges>
        <Badge label="shell" value="bash" color="4EAA25" logo="gnubash" logoColor="white" />
        <Badge label="runtime" value="mise" color="7c3aed" href="https://mise.jdx.dev" />
        <Badge label="providers" value={`${providers.length}`} color="blue" />
        <Badge label="License" value="MIT" color="blue" href="LICENSE" />
      </Badges>
    </Center>

    <Section title="What it does">
      <Paragraph>
        escort provides dashboard providers designed for agent workflows.
        Where <Link href="https://github.com/KnickKnackLabs/hookers">hookers</Link> gives
        you <Code>mail: 93</Code>, escort gives you <Code>mail: 8h 82a 3g</Code> —
        8 from humans, 82 from agents, 3 from GitHub.
      </Paragraph>

      <Paragraph>
        Providers plug directly into hookers' configurable dashboard. No new
        hook wiring needed.
      </Paragraph>
    </Section>

    <Section title="Install">
      <CodeBlock lang="bash">{`shiv install escort`}</CodeBlock>
    </Section>

    <Section title="Quick start">
      <Paragraph>
        Apply the session timer hook (enables elapsed time tracking), then
        update your dashboard config:
      </Paragraph>

      <CodeBlock lang="bash">{`# Apply the session timer hook
hookers add SessionStart "bash -c '# hookers:session-timer
mkdir -p ~/.local/state/escort && date +%s > ~/.local/state/escort/session-start'"

# Use the example config (replaces your current dashboard config)
cp $(shiv which escort)/examples/dashboard.json ~/.config/hookers/dashboard.json`}</CodeBlock>

      <Paragraph>
        Or add individual providers to your existing config:
      </Paragraph>

      <CodeBlock lang="json">{JSON.stringify({
  items: [
    { label: "mail", command: "escort provider mail-breakdown" },
    { label: "prs", command: "escort provider open-prs" },
    { label: "agents", command: "escort provider active-agents" },
    { label: "elapsed", command: "escort provider session-elapsed" },
    { label: "ci", command: "escort provider ci-status" },
  ],
}, null, 2)}</CodeBlock>
    </Section>

    <Section title="Providers">
      <Table>
        <TableHead>
          <Cell>Provider</Cell>
          <Cell>Description</Cell>
          <Cell>Example output</Cell>
        </TableHead>
        {providers.map((p) => (
          <TableRow>
            <Cell><Code>{p.name}</Code></Cell>
            <Cell>{p.desc}</Cell>
            <Cell><Code>{p.example}</Code></Cell>
          </TableRow>
        ))}
      </Table>
    </Section>

    <Section title="Example dashboard">
      <Paragraph>
        With all providers enabled, your dashboard looks like:
      </Paragraph>

      <CodeBlock>{`[dashboard] mail: 8h 82a 3g | prs: 5 open 1 review | agents: k7r2 rho | ci: pass | elapsed: 47m | branch: main | gh-token: 5d`}</CodeBlock>

      <Paragraph>
        This fires on every prompt via hookers' <Code>UserPromptSubmit</Code> hook.
        Providers run in parallel — total latency is bounded by the slowest
        provider (~850ms worst case).
      </Paragraph>
    </Section>

    <Section title="Roadmap">
      <Paragraph>
        escort will evolve beyond static providers into a predictive context agent:
      </Paragraph>

      <CodeBlock>{`Providers (current)  →  Predictive hints  →  Escort agent
Static data              Pattern-matched       Intelligent sidecar
                         command suggestions    that anticipates needs`}</CodeBlock>

      <Paragraph>
        See the <Link href="https://github.com/KnickKnackLabs/escort/issues">open issues</Link> for
        what's planned.
      </Paragraph>
    </Section>

    <Section title="Development">
      <CodeBlock lang="bash">{`git clone https://github.com/KnickKnackLabs/escort.git
cd escort && mise trust && mise install`}</CodeBlock>
    </Section>

    <Center>
      <Section title="License">
        <Paragraph>MIT</Paragraph>
      </Section>

      <Paragraph>
        {"This README was created using "}
        <Link href="https://github.com/KnickKnackLabs/readme">readme</Link>.
      </Paragraph>
    </Center>
  </>
);

console.log(readme);
