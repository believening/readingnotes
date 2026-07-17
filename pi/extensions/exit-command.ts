/**
 * Exit Command Extension
 *
 * Adds a /exit command that behaves the same as pi's built-in /quit command.
 * Triggers a clean graceful shutdown of pi.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Exit pi (same as /quit)",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}
