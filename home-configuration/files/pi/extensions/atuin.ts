/**
 * Atuin extension for pi.
 *
 * Tracks bash commands executed by pi in Atuin history with author `pi`.
 *
 * Install with:
 *   atuin hook install pi
 *
 * Then restart pi or run /reload.
 */

import type { BashToolCallEvent, ExtensionAPI } from "@gsd/pi-coding-agent";

const ATUIN_AUTHOR = "pi";
const ATUIN_TIMEOUT_MS = 10_000;

export default function atuinPiExtension(pi: ExtensionAPI) {
	const pendingHistory = new Map<string, string>(); // toolCallId -> atuin history ID

	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return;
		const command = (event as BashToolCallEvent).input.command;

		try {
			const result = await pi.exec(
				"atuin",
				["history", "start", "--author", ATUIN_AUTHOR, "--", command],
				{ timeout: ATUIN_TIMEOUT_MS },
			);
			if (result.code !== 0) return;
			const id = result.stdout.trim();
			if (id) pendingHistory.set(event.toolCallId, id);
		} catch {
			// Ignore Atuin failures so command execution is never blocked.
		}
	});

	pi.on("tool_result", async (event) => {
		if (event.toolName !== "bash") return;
		const historyId = pendingHistory.get(event.toolCallId);
		if (!historyId) return;
		pendingHistory.delete(event.toolCallId);

		try {
			await pi.exec(
				"atuin",
				["history", "end", historyId, "--exit", event.isError ? "1" : "0"],
				{ timeout: ATUIN_TIMEOUT_MS },
			);
		} catch {
			// Ignore Atuin failures so command execution is never blocked.
		}
	});
}
