# AI content attribution

CrispAssist explanations and step narration are generated prose. Their dialogs
show **AI-generated explanation** and a review reminder, separate from the
calculator's computed result. The explicit copy menu exports either labeled
text or a JSON envelope (`crisp_math.ai_output.v1`) containing the exact displayed
content, completion status, and response attribution.

The attribution records an allowlisted public provider host, the requested model,
the response model when the provider actually returns one, and the time the app
received the response. Private, custom, and tenant hosts become generic
configured/local endpoint labels. Model values that look like paths or URLs are
omitted. Credentials, URL paths, and query parameters are excluded.
Streaming output retains attribution when an HTTP chunk splits an SSE line.
Cancelled, truncated, or unconfirmed completion is not exported as complete.

Natural-language conversion to a calculator expression and cloud OCR have an
adjacent **AI-assisted expression/transcription** notice. The expression and raw
LaTeX remain unmarked strings so insertion, editing, parsing, and calculation
continue to work. Local OCR without this metadata and computed mathematical
results are not labeled as generated explanations. Input-assistance metadata is
not retroactively invented for existing worksheets/history.

These records are application-level provenance. They are not cryptographic
signatures, statistical watermarks, or a guarantee of AI Act compliance. A user
can still select a substring from the dialog without its surrounding attribution;
the explicit copy menu is the portable attributed route. There is no new claim
that an explanation was reviewed by a person or that its correctness is proved.

Focused checks: `ai_output_attribution_test.dart`, `ai_content_notice_test.dart`,
`ai_provider_service_test.dart`, `ai_math_dialog_test.dart`, and the local mock
HTTP/SSE tests in `crisp_assist_integration_test.dart`. No live model call is
required.
