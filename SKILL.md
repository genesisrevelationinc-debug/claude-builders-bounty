## Skill: Generate Changelog

<claude_info>
<icon>file-text</icon>
<activation>
<\/activation>
</claude_info>

<skill_presentation>
<h2>Generate Changelog</h2>
<p>This skill automatically generates a structured CHANGELOG.md from the project's git history.</p>
</skill_presentation>

<additional_skills_note>
<p>This skill works in conjunction with other changelog-related skills.</p>
</additional_skills_note>

<justification>
<p>This changelog generator skill automates the process of creating a structured changelog from git history. It analyzes commits since the last tag and organizes them into Added, Fixed, Changed, and Removed categories.</p>
</justification>

<fulfillment_plan>
<p>The user wants a structured changelog generated from the project's git history, organized by the types of changes.</p>
</fulfillment_plan>

<next_actions>
<ul>
<li>Run the changelog generation script</li>
<li>Execute the changelog generation script with the appropriate parameters</li>
<li>Save the generated changelog to a file</li>
</ul>
</next_actions>

<dependencies>
<p>Requires git to be installed and available in the system PATH.</p>
</dependencies>

<caveats>
<p>May not capture all edge cases in commit message categorization. Review the generated changelog before publishing.</p>
</caveats>

<data_for_demo>
<p>Here's a sample output of a generated changelog:</p>
<pre>
## [0.2.1] - 2024-01-15
### Added
- New feature X
- New feature Y

### Fixed
- Fixed bug in login flow
- Resolved issue with data loading

### Changed
- Updated UI components
- Modified API endpoints

### Removed
- Legacy authentication method
</pre>
</data_for_demo>

<final_artifact>
<p>Generated CHANGELOG.md file with structured release notes</p>
</final_artifact>

<qa>
<q>What formatting should I use for the changelog entries?</q>
<a>Use the conventional changelog format with categories: Added, Fixed, Changed, Removed, prefixed by '###' and the category name.</a>
</qa>

<qa>
<q>How should I handle uncategorized commits?</q>
<q>Should I include the date in the changelog?</q>
<a>No, dates are not typically included in conventional changelogs. The categorization is based on commit message keywords.</a>
</qa>
</ul>
</qa>
</ul>
<ul>
<qa>
<q>How do I format the changelog sections?</q>
<a>Each section should be formatted as a markdown list under the appropriate category heading.</a>
</qa>
</ul>
</skill_presentation>

<script src="skills/generate_changelog.sh" />
</dependencies>