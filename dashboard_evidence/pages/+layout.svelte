<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;
</script>

<EvidenceDefaultLayout
    title='🌐 Global Financial Inclusion 2021 Dashboard'
    githubRepo='https://github.com/jarcelao/global-financial-inclusion'
    {data}
>
	<slot slot="content" />
</EvidenceDefaultLayout>
