<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="統計時間">
              <j-date placeholder="請選擇統計時間" v-model="queryParam.usageDate"></j-date>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24" >
            <a-form-model-item label="專案名稱"  >
              <a-select v-model="queryParam.projectId"  placeholder="請選擇專案" >
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展開' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>
      <a-button type="primary" icon="download" @click="handleExportXls('資源用量表')">導出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">導入</a-button>
      </a-upload>
      <!-- 高級查詢區域 -->
      <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table區域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">編輯</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">詳情</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="確定刪除嗎?" @confirm="() => handleDelete(record.id)">
                  <a>刪除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-resource-usage-modal ref="modalForm" @ok="modalFormOk"></os-resource-usage-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import OsResourceUsageModal from './modules/OsResourceUsageModal'
  import { httpAction,getAction } from '@/api/manage'

  let showProjects = [];

  export default {
    name: 'OsResourceUsageList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsResourceUsageModal
    },
    data () {

      //根據ID顯示名稱
      function toNamebyId(text) {
        let res = "";
        showProjects.forEach((r)=>{
          if(r.value == text){
            res =  r.text;
          }
        })
        return res;
      }
      return {
        description: '資源用量表管理頁面',
        // 表頭
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'統計時間',
            align:"center",
            dataIndex: 'usageDate',
            sorter: true,
            customRender:function (text) {
              return !text?"":(text.length>10?text.substr(0,10):text)
            }
          },
          {
            title:'專案名稱',
            align:"center",
            dataIndex: 'projectId',
            customRender:function (text) {
              return toNamebyId(text)
            }
          },
          {
            title:'內存用量',
            align:"center",
            dataIndex: 'ram'
          },
          {
            title:'週期內CPU-小時數',
            align:"center",
            dataIndex: 'totalVcpusUsage'
          },
          {
            title:'週期內磁盤GB-小時數',
            align:"center",
            dataIndex: 'totalLocalGbUsage'
          },
          {
            title:'週期內的 RAM-小時數',
            align:"center",
            dataIndex: 'totalMemoryMbUsage'
          },
          {
            title:'總運行時長',
            align:"center",
            dataIndex: 'totalHours'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          getProject: "/os/osApply/getProject",
          list: "/openstack/osResourceUsage/list",
          delete: "/openstack/osResourceUsage/delete",
          deleteBatch: "/openstack/osResourceUsage/deleteBatch",
          exportXlsUrl: "/openstack/osResourceUsage/exportXls",
          importExcelUrl: "openstack/osResourceUsage/importExcel",

        },
        dictOptions:{},
        superFieldList:[],
        projects:[],
      }
    },
    created() {
      this.loadProjects();
      this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      loadProjects(){
        let method = "post";
        let httpurl = this.url.getProject;
        let that = this;
        httpAction(httpurl, { },method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
            showProjects = this.projects;
            if(result.length>0){
              let url = that.url.getDateCountInfo
              that.loadDate(url,'date',{})
            }
          }
        })
      },
      initDictConfig(){
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'date',value:'usageDate',text:'統計時間'})
        fieldList.push({type:'int',value:'ram',text:'內存用量',dictCode:''})
        fieldList.push({type:'BigDecimal',value:'totalVcpusUsage',text:'週期內CPU-小時數',dictCode:''})
        fieldList.push({type:'BigDecimal',value:'totalLocalGbUsage',text:'週期內磁盤GB-小時數',dictCode:''})
        fieldList.push({type:'BigDecimal',value:'totalMemoryMbUsage',text:'週期內的 RAM-小時數',dictCode:''})
        fieldList.push({type:'string',value:'totalHours',text:'總運行時長',dictCode:''})
        this.superFieldList = fieldList
      },
      toNamebyId(value){

      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>